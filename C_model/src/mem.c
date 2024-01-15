#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "mem.h"
#include "ElfObj.h"

#define STACK_TOP 0x80000000
#define STACK_SIZE 4096

typedef struct _seg
	{
	uint32_t va;
	void *ra;
	size_t size;
	struct _seg *next;
	}Seg;

static Seg *TabSeg = NULL;

uint32_t GoodAdr;
uint32_t BadAdr;

uint32_t mem_goodadr()
	{
	return GoodAdr;
	}
	
uint32_t mem_badadr()
	{
	return BadAdr;
	}

int mem_add_seg(uint32_t adr, size_t size, void *src)
	{
	Seg *ps = TabSeg;
	Seg *new_seg = NULL;

	if (ps == NULL)
		{
		if ((TabSeg = malloc(sizeof(Seg))) == NULL) return 0;
		if ((TabSeg->ra = malloc(size)) == NULL) return 0;
		if (src) memcpy(TabSeg->ra, src, size);
		TabSeg->va = adr;
		TabSeg->size = size;
		TabSeg->next = NULL;
		return 1;
		}
	
	if (adr < ps->va)
		{
		if ((adr + size) > ps->va) return 0; //memory already alloc
		if ((TabSeg = malloc(sizeof(Seg))) == NULL) return 0;
		if ((TabSeg->ra = malloc(size)) == NULL) return 0;
		if (src) memcpy(TabSeg->ra, src, size);
		TabSeg->va = adr;
		TabSeg->size = size;
		TabSeg->next = ps;
		return 1;
		}
	
	while (ps->next)
		{
		if (ps->next->va > adr) break;
		ps = ps->next;
		}

	if (adr < (ps->va + ps->size)) return 0; //memory already alloc
	if (ps->next && ((adr + size) > ps->next->va)) return 0; //memory already alloc
	if ((new_seg = malloc(sizeof(Seg))) == NULL) return 0;
	if ((new_seg->ra = malloc(size)) == NULL) return 0;
	if (src) memcpy(new_seg->ra, src, size);
	new_seg->va = adr;
	new_seg->size = size;
	new_seg->next = ps->next;
	ps->next = new_seg;
	return 1;
	}

uint32_t mem_lw(uint32_t adr)
	{
	Seg *ps = TabSeg;

	if (adr & 3)
		{
		fprintf(stderr, "Mem Error lw adr unalign\n");
		return 0;
		}
	
	while (ps)
		{
		if ((adr >= ps->va) && (adr < ps->va + ps->size))
			{
			return *(uint32_t *) (ps->ra + (adr - ps->va));
			}
		if (adr < ps->va) break;
		ps = ps->next;
		}
	fprintf(stderr, "Mem LW Error adr does not exist: 0x%x\n", adr);
	return 0;
	}

int mem_sw(uint32_t adr, uint32_t data)
	{
	Seg *ps = TabSeg;

	if (adr & 3)
		{
		fprintf(stderr, "Mem Error sw adr unalign\n");
		return 1;
		}
	
	while (ps)
		{
		if ((adr >= ps->va) && (adr < (ps->va + ps->size)))
			{
			*(uint32_t *) (ps->ra + (adr - ps->va)) = data;
			return 0;
			}
		if (adr < ps->va) break;
		ps = ps->next;
		}
	fprintf(stderr, "Mem SW Error adr Ox%x does not exist\n", adr);
	exit(1);
	return 1;
	}

uint8_t mem_lb(uint32_t adr)
	{
	Seg *ps = TabSeg;

	while (ps)
		{
		if ((adr >= ps->va) && (adr < ps->va + ps->size))
			return *(uint8_t *) (ps->ra + (adr - ps->va));
		if (adr < ps->va) break;
		ps = ps->next;
		}
	fprintf(stderr, "Mem Error LB adr does not exist\n");
	return 0;
	}

int mem_sb(uint32_t adr, uint8_t data)
	{
	Seg *ps = TabSeg;

	while (ps)
		{
		if ((adr >= ps->va) && (adr < ps->va + ps->size))
			{
			*(uint8_t *) (ps->ra + (adr - ps->va)) = data;
			return 0;
			}
		if (adr < ps->va) break;
		ps = ps->next;
		}
	fprintf(stderr, "Mem Error SB adr does not exist\n");
	return 1;
	}

void mem_free()
	{
	Seg *ps = TabSeg;
	Seg *next;

	while (ps)
		{
		next = ps->next;
		free(ps->ra);
		free(ps);
		ps = next;
		}
	TabSeg = NULL;
	}

void init_mem(char *Elf_file)
	{
	Elf32_Obj *pObj = NULL;

	if ((pObj = Read_Elf32(Elf_file)) == NULL)
		{
		fprintf(stderr, "Erreur chargement elf\n");
		exit(1);
		}
	
	// Chargement memoire
	// Section text
	if (pObj->SecText)
		if (mem_add_seg(pObj->SecTextHdr->sh_addr, pObj->SecTextHdr->sh_size, pObj->SecText) == 1)
			fprintf(stdout, "Chargement du segment .text adr = 0x%x\n", pObj->SecTextHdr->sh_addr);

	// Section data
	if (pObj->SecData)
		if (mem_add_seg(pObj->SecDataHdr->sh_addr, pObj->SecDataHdr->sh_size, pObj->SecData) == 1)
			fprintf(stdout, "Chargement du segment .data adr = 0x%x\n", pObj->SecDataHdr->sh_addr);
	
	// Section bss
	if (pObj->SecBssHdr)
		if (mem_add_seg(pObj->SecBssHdr->sh_addr, pObj->SecBssHdr->sh_size, NULL) == 1)
			fprintf(stdout, "Chargement du segment .bss adr = 0x%x\n", pObj->SecBssHdr->sh_addr);

	// Stack
	mem_add_seg(STACK_TOP - STACK_SIZE, STACK_SIZE, NULL);
	fprintf(stdout, "Chargement du segment pile adr = 0x%x Taille = 0x%x\n", STACK_TOP - STACK_SIZE, STACK_SIZE);

	// Search good and bad symbols adr
	if (Elf32_SymAdr(pObj, &GoodAdr, "_good") == 0)
		fprintf(stderr, "Symbol _good found at adr=%x\n", GoodAdr);

	if (Elf32_SymAdr(pObj, &BadAdr, "_bad") == 0)
		fprintf(stderr, "Symbol _bad found at adr=%x\n", BadAdr);

	Del_Elf32(pObj);
	}
