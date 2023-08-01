/* intxmlparserutil : scilab interface for expat library
 *                    (utilities functions)
 *
 *  Interfacing functions :
 *  ---------------------
 *     int intxmlstopparser_c(char *fname,unsigned long fname_len)
 *     int intxmlresumeparser_c(char *fname,unsigned long fname_len)
 *
 * Author : A. Layec (alan.layec@inria.fr)
 *          initial revision : 15/09/06
 */

#include "intxmlparser.h"

/* Stop Parser
 *
 * Scilab Calling sequence :
 *   -->XML_StopParser(%ptr,%f);
 *
 */
int intxmlstopparser_c(char *fname,unsigned long fname_len)
{
  static int l1, m1, n1;
  XML_Parser ptr_parser;

  static int m2,n2,l2;
  int resumable;

  int i;

  /* */
  CheckRhs(2,2);

  /*****************************************/
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
     Scierror(999,"%s: "
                  "Rhs(1) : Parser ptr not valid\n",
              fname);
     return(0);
  }
  /*****************************************/

  /* */
  GetRhsVar(2,"b",&m2,&n2,&l2);

  /* */
  resumable= *istk(l2);

  /* */
  XML_StopParser(ptr_parser, resumable);

  return(0);
}

/* Resume Parser
 *
 * Scilab Calling sequence :
 *   -->XML_ResumeParser(%ptr);
 *
 */
int intxmlresumeparser_c(char *fname,unsigned long fname_len)
{
  static int l1, m1, n1;
  XML_Parser ptr_parser;

  int i;

  /* */
  CheckRhs(1,1);

  /*****************************************/
  GetRhsVar(1,"p",&m1,&n1,&l1);
  ptr_parser = (XML_Parser) ((unsigned long int) *stk(l1));

  i=GetIndPtrStruct(ptr_parser);

  if((i==-1)||(i==-2)) {
   Scierror(999,"%s: "
                "Rhs(1) : Parser ptr not valid\n",
            fname);
   return(0);
  }
  /*****************************************/

  /* */
  XML_ResumeParser(ptr_parser);

  return(0);
}
