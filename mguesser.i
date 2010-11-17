/* Copyright (C) 2009 LJA. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
*/


/*
// ******************************** API :
// use MGuesser object to guess :

// Version A : get first hit :
import mguesser
guesser=mguesser.MGuesser()
mapstat=guesser.guess('''bonjour, je m'appelle loic jaquemet  et j'aime les jeux et la creme a la fraise. le pain quotidien de ce jour est durand , dupont joubert''')
print mapstat.quality,mapstat.map.lang,mapstat.map.charset

// Version B : get all results :
import mguesser
guesser=mguesser.MGuesser()
mapstats=guesser.guessArray('''bonjour, je m'appelle loic jaquemet  et j'aime les jeux et la creme a la fraise. le pain quotidien de ce jour est durand , dupont joubert''')
for m in mapstats:
  print m.quality, m.map.lang, m.map.charset

// mem leak tests : 
for i in range(60000):
  mapstats=guesser.guess('''bonjour, je m'appelle loic jaquemet  et j'aime les jeux et la creme a la fraise. le pain quotidien de ce jour est durand , dupont joubert''')
  mapstats=guesser.guessArray('''bonjour, je m'appelle loic jaquemet  et j'aime les jeux et la creme a la fraise. le pain quotidien de ce jour est durand , dupont joubert''')

for i in range(60000):
  guesser=mguesser.MGuesser()


*/

%include "typemaps.i"
%include "cpointer.i"
%include "carrays.i"
%include "cmalloc.i"


%module mguesser
%{
#include "udm_common.h"
extern int UdmLoadLangMapFile(UDM_ENV * Env, const char * filename);
extern int UdmLoadLangMapList(UDM_ENV * Env, const char * mapdir);
extern void UdmBuildLangMap(UDM_LANGMAP * map,const char * text,size_t textlen);
extern void UdmPrintLangMap(UDM_LANGMAP * map);
extern void UdmPrepareLangMap(UDM_LANGMAP * map);
extern float UdmCheckLangMap(UDM_LANGMAP * map0,UDM_LANGMAP * map1);
extern int UdmLoadLangMapListMultipleDirs(UDM_ENV *Env, const char *mapdirs);
extern void UdmFreeLangMapList(UDM_ENV * env);
extern void usage();
%}
%include "udm_common.h" 
extern int UdmLoadLangMapFile(UDM_ENV * Env, const char * filename);
extern int UdmLoadLangMapList(UDM_ENV * Env, const char * mapdir);
extern void UdmBuildLangMap(UDM_LANGMAP * map,const char * text,size_t textlen);
extern void UdmPrintLangMap(UDM_LANGMAP * map);
extern void UdmPrepareLangMap(UDM_LANGMAP * map);
extern float UdmCheckLangMap(UDM_LANGMAP * map0,UDM_LANGMAP * map1);
extern int UdmLoadLangMapListMultipleDirs(UDM_ENV *Env, const char *mapdirs);
extern void UdmFreeLangMapList(UDM_ENV * env);
extern void usage();
/* int  UdmGuessCharSet(UDM_AGENT * Indexer,UDM_DOCUMENT * Doc);*/


/*  void guess(char * buf, UDM_MAPSTAT * mapstat); */ 
UDM_MAPSTAT * guessold(char * buf);
UDM_MAPSTAT * guess(UDM_ENV * env, char * buf);
//UDM_MAPSTAT[] guessList(UDM_ENV * env, char * buf);
UDM_ENV * buildEnv();
UDM_LANGMAP * buildLangMap();


%pythoncode %{

class MGuesser():
  def __init__(self):
    self.env=buildEnv()
    #self.mchar=buildLangMap()
    pass
  def __del__(self):
    if(self.env):
      UdmFreeLangMapList(self.env)
  # moue... et le free() ?
  def guess(self,buf):
    arra=guess(self.env,buf)
    ret = mapStatArray_getitem(arra,0)
    delete_mapStatArray(arra)
    return ret
  def guessArray(self,buf):
    #new_mapStatArray(int)
    #delete_mapStatArray(array)
    #mapStatArray_getitem(array,int)
    #mapStatArray_setitem(array,int,val)
    arra=guess(self.env,buf)
    ret=[]
    for i in range(self.env.LangMapList.nmaps):
      ret.append(mapStatArray_getitem(arra,i))
    delete_mapStatArray(arra)
    return ret

def test():
  data="""But some manual pages are modified in Debian, and it is
difficult to ensure that translations are accurate.  For
these reasons, we decided to fork these translations and
manage them with po4a.  Translations are now maintained
by various contributors of the debian-l10n-french mailing
list, based on previous translations by Christophe Blaess
and Alain Portal.
  """
  langGuesser=MGuesser()
  mapstat=langGuesser.guess(data)
  print "guessed %s : lang:%s quality:%2.2f "%('data',mapstat.map.lang,mapstat.quality) 
  return


%}

%inline %{

/* Structure to sort guesser results */
typedef struct
{
  UDM_LANGMAP * map;

  float quality;
} UDM_MAPSTAT;

int statcmp(const void * i1, const void * i2)
{
  float fres;
  fres= ((UDM_MAPSTAT*)(i2))->quality - ((UDM_MAPSTAT*)(i1))->quality;
  if (fres<0) return -1;
  if (fres>0) return +1;
  return 0;
}

UDM_ENV * buildEnv()
{
  UDM_ENV * env;
  const char *dir= LMDIR;
  env=(UDM_ENV *) malloc(sizeof(UDM_ENV));
  memset(env,0,sizeof(UDM_ENV));
  UdmLoadLangMapListMultipleDirs(env, dir);
  if(env->errcode)
  {
    printf("Error: '%s'\n",env->errstr);
    return NULL;
  }
  return env;
}

UDM_LANGMAP * buildLangMap()
{
  UDM_LANGMAP * mchar;
  mchar=(UDM_LANGMAP *) malloc(sizeof(UDM_LANGMAP ));
  memset(mchar,0,sizeof(*mchar));
  mchar->topcount = UDM_LM_TOPCNT;

  return mchar;
}



UDM_MAPSTAT * guess(UDM_ENV * env, char * buf)
{
  int i;
  UDM_MAPSTAT * mapstat;
  UDM_LANGMAP * mchar;
  mchar=buildLangMap();

  UdmBuildLangMap(mchar,buf,strlen(buf));

  /* Prepare map to comparison */
  UdmPrepareLangMap(mchar);

  /* Allocate memory for comparison statistics */
  mapstat= (UDM_MAPSTAT *)malloc(env->LangMapList.nmaps*sizeof(UDM_MAPSTAT));

  /* Calculate each lang map        */
  /* correlation with text          */
  /* and store in mapstat structure */

  for (i= 0; i < env->LangMapList.nmaps; i++)
  {
    mapstat[i].quality= UdmCheckLangMap(&env->LangMapList.maps[i],mchar);
    mapstat[i].map= &env->LangMapList.maps[i];
    //printf("mapstat[%d]: quality:%2.2f lang:%s\n",i,mapstat[i].quality,mapstat[i].map->lang);
  }

  /* Sort statistics in quality order */
  qsort(mapstat,env->LangMapList.nmaps,sizeof(UDM_MAPSTAT),&statcmp);

  /* UdmFreeLangMapList(&env); */
  free(mchar);
  
  /* return matches - need free() free(mapstat); */
  //return mapstat[0];
  return mapstat;
}


UDM_MAPSTAT * guessold(char * buf)
{
  UDM_ENV env;
  UDM_LANGMAP mchar;
  const char *dir= LMDIR;

  /* Init structures */
  memset(&env,0,sizeof(env));
  memset(&mchar,0,sizeof(mchar));
  mchar.topcount= UDM_LM_TOPCNT;

  /* On charge les maps */
  UdmLoadLangMapListMultipleDirs(&env, dir);
  if(env.errcode)
  {
    //UDM_MAPSTAT mapstatnull;
    printf("Error: '%s'\n",env.errstr);
    return NULL;
    //return mapstatnull;
    //return;
  }
  
  
  /* Add each STDIN line statistics */
  /*while(fgets(buf,sizeof(buf),stdin))
  { } */
  // TODO : BUF
  UdmBuildLangMap(&mchar,buf,strlen(buf));
  
  int i;
  // comment if returned...
  UDM_MAPSTAT * mapstat;
  
  
  /* Prepare map to comparison */
  UdmPrepareLangMap(&mchar);

  /* Allocate memory for comparison statistics */
  mapstat= (UDM_MAPSTAT *)malloc(env.LangMapList.nmaps*sizeof(UDM_MAPSTAT));

  /* Calculate each lang map        */
  /* correlation with text          */
  /* and store in mapstat structure */

  for (i= 0; i < env.LangMapList.nmaps; i++)
  {
    mapstat[i].quality= UdmCheckLangMap(&env.LangMapList.maps[i],&mchar);
    mapstat[i].map= &env.LangMapList.maps[i];
  }

  /* Sort statistics in quality order */
  qsort(mapstat,env.LangMapList.nmaps,sizeof(UDM_MAPSTAT),&statcmp);

  /* UdmFreeLangMapList(&env); */
 
  /* return matches - need free() free(mapstat); */
  //return mapstat[0];
  return mapstat;
  //return;
}


%}




%array_functions(UDM_MAPSTAT, mapStatArray);
/* %array_class(UDM_MAPSTAT, int); */

/* no use...
%extend UDM_MAPSTAT {
	~UDM_MAPSTAT() {
		free($self);
};
*/



/* Set the input argument to point to a temporary variable */
/*
%typemap(in, numinputs=0) int *out (int temp) {
   $1 = &temp;
}
%typemap(argout) int *out {
   // Append output value $1 to $result
}
*/


