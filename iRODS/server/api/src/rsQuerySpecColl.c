/* -*- mode: c++; fill-column: 132; c-basic-offset: 4; indent-tabs-mode: nil -*- */

/*** Copyright (c), The Unregents of the University of California            ***
 *** For more information please refer to files in the COPYRIGHT directory ***/
/* rsQuerySpecColl.c
 */

#include "querySpecColl.h"
#include "rcMisc.h"
#include "fileOpendir.h"
#include "fileReaddir.h"
#include "fileClosedir.h"
#include "objMetaOpr.h"
#include "specColl.h"
#include "dataObjClose.h"
#include "subStructFileOpendir.h"
#include "subStructFileReaddir.h"
#include "subStructFileClosedir.h"
#include "fileStat.h"
#include "genQuery.h"
#include "rsGlobalExtern.h"
#include "rcGlobalExtern.h"

// =-=-=-=-=-=-=-
// eirods includes
#include "eirods_resource_backport.h"
#include "eirods_resource_redirect.h"
#include "eirods_stacktrace.h"
#include "eirods_hierarchy_parser.h"


int
rsQuerySpecColl (rsComm_t *rsComm, dataObjInp_t *dataObjInp,
                 genQueryOut_t **genQueryOut)
{

    int specCollInx;
    int status;
    int continueFlag;   /* continue query */ 
    int remoteFlag;
    rodsServerHost_t *rodsServerHost;
    remoteFlag = getAndConnRcatHost (rsComm, SLAVE_RCAT, dataObjInp->objPath,
                                     &rodsServerHost);

    if (remoteFlag < 0) {
        return (remoteFlag);
    } else if (remoteFlag == REMOTE_HOST) {
        status = rcQuerySpecColl (rodsServerHost->conn, dataObjInp,
                                  genQueryOut);
        return status;
    }

    // =-=-=-=-=-=-=-
    // working on the "home zone", determine if we need to redirect to a different
    // server in this zone for this operation.  if there is a RESC_HIER_STR_KW then
    // we know that the redirection decision has already been made
    std::string       hier;
    int               local = LOCAL_HOST;
    rodsServerHost_t* host  =  0;
    char* hier_kw;
    if( ( hier_kw = getValByKey( &dataObjInp->condInput, RESC_HIER_STR_KW ) ) == NULL ) {
        eirods::error ret = eirods::resource_redirect( eirods::EIRODS_OPEN_OPERATION, rsComm, 
                                                       dataObjInp, hier, host, local );
        if( !ret.ok() ) { 
            std::stringstream msg;
            msg << "rsDataObjGet :: failed in eirods::resource_redirect for [";
            msg << dataObjInp->objPath << "]";
            eirods::log( PASSMSG( msg.str(), ret ) );
            return ret.code();
        }
   
        // =-=-=-=-=-=-=-
        // we resolved the redirect and have a host, set the hier str for subsequent
        // api calls, etc.
        addKeyVal( &dataObjInp->condInput, RESC_HIER_STR_KW, hier.c_str() );

    } 

    if ((specCollInx = dataObjInp->openFlags) <= 0) {
        specCollInx = openSpecColl (rsComm, dataObjInp, -1);
        if (specCollInx < 0) {
            rodsLog (LOG_NOTICE,
                     "rsQuerySpecColl: openSpecColl error for %s, status = %d",
                     dataObjInp->objPath, specCollInx);
            return (specCollInx);
        }
        continueFlag = 0;
    } else {
        continueFlag = 1;
    }
        
    initOutForQuerySpecColl (genQueryOut);

    status = _rsQuerySpecColl (rsComm, specCollInx, dataObjInp,
                               *genQueryOut, continueFlag);

    if (status < 0) {
        freeGenQueryOut (genQueryOut);
    }
    return (status);
}

int
openSpecColl (rsComm_t *rsComm, dataObjInp_t *dataObjInp, int parentInx)
{
    int specCollInx;
    dataObjInfo_t *dataObjInfo = NULL;
    int status;
    int l3descInx;

    status = resolvePathInSpecColl (rsComm, dataObjInp->objPath, 
                                    //READ_COLL_PERM, 0, &dataObjInfo);
                                    UNKNOW_COLL_PERM, 0, &dataObjInfo);

    if (status < 0 || NULL == dataObjInfo ) { // JMC cppcheck - nullptr
        rodsLog (LOG_NOTICE,
                 "rsQuerySpecColl: resolveSpecColl error for %s, status = %d",
                 dataObjInp->objPath, status);
        return (status);
    }

    if (dataObjInfo->specColl->collClass == LINKED_COLL) {
        rodsLog (LOG_ERROR,
                 "rsQuerySpecColl: %s is a linked collection",
                 dataObjInp->objPath);
        return SYS_UNKNOWN_SPEC_COLL_CLASS;
    }

    char* resc_hier = getValByKey( &dataObjInp->condInput, RESC_HIER_STR_KW );
    if( resc_hier ) {
        strncpy( dataObjInfo->rescHier, resc_hier, MAX_NAME_LEN );
    }

    l3descInx = l3Opendir (rsComm, dataObjInfo);

    if (l3descInx < 0) {
        rodsLog (LOG_NOTICE,
                 "openSpecColl: specCollOpendir error for %s, status = %d",
                 dataObjInp->objPath, l3descInx);
        return (l3descInx);
    }
    specCollInx = allocSpecCollDesc ();
    if (specCollInx < 0) {
        freeDataObjInfo (dataObjInfo);
        return (specCollInx);
    }
    SpecCollDesc[specCollInx].l3descInx = l3descInx;
    SpecCollDesc[specCollInx].dataObjInfo = dataObjInfo; 
    SpecCollDesc[specCollInx].parentInx = parentInx;

    return (specCollInx);
}

int
initOutForQuerySpecColl (genQueryOut_t **genQueryOut)
{
    genQueryOut_t *myGenQueryOut;

    /* will do collection, dataName, createTime, modifyTime, objSize */

    myGenQueryOut = *genQueryOut = 
        (genQueryOut_t *) malloc (sizeof (genQueryOut_t));

    memset (myGenQueryOut, 0, sizeof (genQueryOut_t));

    myGenQueryOut->attriCnt = 5;

    myGenQueryOut->sqlResult[0].attriInx = COL_COLL_NAME;
    myGenQueryOut->sqlResult[0].len = MAX_NAME_LEN;    
    myGenQueryOut->sqlResult[0].value = 
        (char*)malloc (MAX_NAME_LEN * MAX_SPEC_COLL_ROW);
    memset (myGenQueryOut->sqlResult[0].value, 0, 
            MAX_NAME_LEN * MAX_SPEC_COLL_ROW);
    myGenQueryOut->sqlResult[1].attriInx = COL_DATA_NAME;
    myGenQueryOut->sqlResult[1].len = MAX_NAME_LEN; 
    myGenQueryOut->sqlResult[1].value = 
        (char*)malloc (MAX_NAME_LEN * MAX_SPEC_COLL_ROW);
    memset (myGenQueryOut->sqlResult[1].value, 0, 
            MAX_NAME_LEN * MAX_SPEC_COLL_ROW);
    myGenQueryOut->sqlResult[2].attriInx = COL_D_CREATE_TIME;
    myGenQueryOut->sqlResult[2].len = NAME_LEN;
    myGenQueryOut->sqlResult[2].value =
        (char*)malloc (NAME_LEN * MAX_SPEC_COLL_ROW);
    memset (myGenQueryOut->sqlResult[2].value, 0,
            NAME_LEN * MAX_SPEC_COLL_ROW); 
    myGenQueryOut->sqlResult[3].attriInx = COL_D_MODIFY_TIME;
    myGenQueryOut->sqlResult[3].len = NAME_LEN;
    myGenQueryOut->sqlResult[3].value =
        (char*)malloc (NAME_LEN * MAX_SPEC_COLL_ROW);
    memset (myGenQueryOut->sqlResult[3].value, 0,
            NAME_LEN * MAX_SPEC_COLL_ROW);     
    myGenQueryOut->sqlResult[4].attriInx = COL_DATA_SIZE;
    myGenQueryOut->sqlResult[4].len = NAME_LEN;
    myGenQueryOut->sqlResult[4].value =
        (char*)malloc (NAME_LEN * MAX_SPEC_COLL_ROW);
    memset (myGenQueryOut->sqlResult[4].value, 0,
            NAME_LEN * MAX_SPEC_COLL_ROW);

    myGenQueryOut->continueInx = -1;

    return (0);
}

int
_rsQuerySpecColl (rsComm_t *rsComm, int specCollInx, 
                  dataObjInp_t *dataObjInp, genQueryOut_t *genQueryOut, int continueFlag)
{
    int status;
    rodsDirent_t *rodsDirent = NULL;
    dataObjInfo_t *dataObjInfo;
    rodsStat_t *fileStatOut = NULL;
    int rowCnt;
    objType_t selObjType;
    char *tmpStr;
    dataObjInp_t newDataObjInp;
    int recurFlag;

    if (SpecCollDesc[specCollInx].inuseFlag != FD_INUSE) {
        rodsLog (LOG_ERROR,
                 "_rsQuerySpecColl: Input specCollInx %d not active", specCollInx);
        return (BAD_INPUT_DESC_INDEX);
    }

    if ((tmpStr = getValByKey (&dataObjInp->condInput, SEL_OBJ_TYPE_KW)) != 
        NULL) {
        if (strcmp (tmpStr, "dataObj") == 0) {
            selObjType = DATA_OBJ_T;
        } else {
            selObjType = COLL_OBJ_T;
        }
    } else {
        selObjType = UNKNOWN_OBJ_T;
    }

    if (getValByKey (&dataObjInp->condInput, RECURSIVE_OPR__KW) != NULL) {
        recurFlag = 1;
    } else {
        recurFlag = 0;
    }

    dataObjInfo = SpecCollDesc[specCollInx].dataObjInfo;

    while (genQueryOut->rowCnt < MAX_SPEC_COLL_ROW) {
        dataObjInfo_t myDataObjInfo;
        rodsDirent_t myRodsDirent;

        status = specCollReaddir (rsComm, specCollInx, &rodsDirent);

        if (status < 0) {
            break;
        }
        
        myRodsDirent = *rodsDirent;
        free (rodsDirent);

        if (strcmp (myRodsDirent.d_name, ".") == 0 ||
            strcmp (myRodsDirent.d_name, "..") == 0) {
            continue;
        } 

        myDataObjInfo = *dataObjInfo;
        
        snprintf( myDataObjInfo.subPath, MAX_NAME_LEN, "%s/%s",
                  dataObjInfo->subPath, myRodsDirent.d_name);
        snprintf( myDataObjInfo.filePath, MAX_NAME_LEN, "%s/%s",
                  dataObjInfo->filePath, myRodsDirent.d_name);

        status = l3Stat (rsComm, &myDataObjInfo, &fileStatOut);
        if (status < 0) {
            rodsLog (LOG_ERROR,
                     "_rsQuerySpecColl: l3Stat for %s error, status = %d",
                     myDataObjInfo.filePath, status);
            /* XXXXX need clean up */
            return (status);
        }
        
        if ((fileStatOut->st_mode & S_IFREG) != 0) {     /* a file */
            if (selObjType == COLL_OBJ_T) {
                free (fileStatOut);
                continue;
            }
            rowCnt = genQueryOut->rowCnt;
            rstrcpy (&genQueryOut->sqlResult[0].value[MAX_NAME_LEN * rowCnt], 
                     dataObjInfo->subPath, MAX_NAME_LEN);
            rstrcpy (&genQueryOut->sqlResult[1].value[MAX_NAME_LEN * rowCnt], 
                     myRodsDirent.d_name, MAX_NAME_LEN);
            snprintf (&genQueryOut->sqlResult[2].value[NAME_LEN * rowCnt],
                      NAME_LEN, "%d", fileStatOut->st_ctim);
            snprintf (&genQueryOut->sqlResult[3].value[NAME_LEN * rowCnt],
                      NAME_LEN, "%d", fileStatOut->st_mtim);
            snprintf (&genQueryOut->sqlResult[4].value[NAME_LEN * rowCnt],
                      NAME_LEN, "%lld", fileStatOut->st_size);

            free (fileStatOut);

            genQueryOut->rowCnt++;

        } else {
            if (selObjType != DATA_OBJ_T) {
                rowCnt = genQueryOut->rowCnt;
                rstrcpy( &genQueryOut->sqlResult[0].value[MAX_NAME_LEN * rowCnt],
                         myDataObjInfo.subPath, MAX_NAME_LEN );
                snprintf( &genQueryOut->sqlResult[2].value[NAME_LEN * rowCnt],
                          NAME_LEN, "%d", fileStatOut->st_ctim);
                snprintf (&genQueryOut->sqlResult[3].value[NAME_LEN * rowCnt],
                          NAME_LEN, "%d", fileStatOut->st_mtim);
                snprintf (&genQueryOut->sqlResult[4].value[NAME_LEN * rowCnt],
                          NAME_LEN, "%lld", fileStatOut->st_size);
                genQueryOut->rowCnt++;
            }
            
            free (fileStatOut);

            if (recurFlag > 0) {
                /* need to drill down */
                int newSpecCollInx; 
                newDataObjInp = *dataObjInp;
                rstrcpy (newDataObjInp.objPath, dataObjInfo->subPath,
                         MAX_NAME_LEN);
                newSpecCollInx = 
                    openSpecColl (rsComm, &newDataObjInp, specCollInx);
                if (newSpecCollInx < 0) {
                    rodsLog (LOG_ERROR,
                             "_rsQuerySpecColl: openSpecColl err for %s, stat = %d",
                             newDataObjInp.objPath, newSpecCollInx);
                    status = newSpecCollInx;
                    break;
                }
                status = _rsQuerySpecColl (rsComm, newSpecCollInx, 
                                           &newDataObjInp, genQueryOut, 0);
                if (status < 0) {
                    break;
                }
            }
        }
    } // while 

    if (status == EOF || status == CAT_NO_ROWS_FOUND) {
        status = 0;
    }

    if (genQueryOut->rowCnt < MAX_SPEC_COLL_ROW) {
        int parentInx;
        /* get to the end or error */
        specCollClosedir (rsComm, specCollInx);
        parentInx = SpecCollDesc[specCollInx].parentInx;
        freeSpecCollDesc (specCollInx);
        if (status >= 0 && recurFlag && continueFlag && parentInx > 0) {
            newDataObjInp = *dataObjInp; 
            rstrcpy (newDataObjInp.objPath, 
                     SpecCollDesc[parentInx].dataObjInfo->objPath, MAX_NAME_LEN);
            status = _rsQuerySpecColl (rsComm, parentInx,
                                       &newDataObjInp, genQueryOut, continueFlag);
        } else {
            /* no more */
            genQueryOut->continueInx = -1;
        }
        if (status == EOF || status == CAT_NO_ROWS_FOUND) {
            status = 0;
        }
    } else {
        /* more to come */
        if (genQueryOut->continueInx < 0) {
            /* if one does not already exist */
            genQueryOut->continueInx = specCollInx;
        }
    }

    if (status >= 0 && genQueryOut->rowCnt == 0) {
        status = CAT_NO_ROWS_FOUND;
    }  
    
    return (status);
}

int 
specCollReaddir (rsComm_t *rsComm, int specCollInx, rodsDirent_t **rodsDirent)
{
    fileReaddirInp_t fileReaddirInp;
    specColl_t *specColl;
    int status;
    dataObjInfo_t *dataObjInfo = SpecCollDesc[specCollInx].dataObjInfo;

    if (dataObjInfo == NULL || (specColl = dataObjInfo->specColl) == NULL) {
        return (SYS_INTERNAL_NULL_INPUT_ERR);
    }

    // =-=-=-=-=-=-=-
    // get the resc location of the hier leaf
    std::string location;
    eirods::error ret = eirods::get_loc_for_hier_string( dataObjInfo->rescHier, location );
    if( !ret.ok() ) {
        eirods::log( PASSMSG( "specCollReaddir - failed in get_loc_for_hier_string", ret ) );
        return -1;
    }


    if (getStructFileType (dataObjInfo->specColl) >= 0) {
        subStructFileFdOprInp_t subStructFileReaddirInp;
        memset (&subStructFileReaddirInp, 0, sizeof (subStructFileReaddirInp));
        subStructFileReaddirInp.type = dataObjInfo->specColl->type;
        subStructFileReaddirInp.fd = SpecCollDesc[specCollInx].l3descInx;
        rstrcpy (subStructFileReaddirInp.addr.hostAddr, 
                 location.c_str(), NAME_LEN);
        status = rsSubStructFileReaddir (rsComm, &subStructFileReaddirInp, 
                                         rodsDirent);
    } else if (specColl->collClass == MOUNTED_COLL) {
        fileReaddirInp.fileInx = SpecCollDesc[specCollInx].l3descInx;
        status = rsFileReaddir (rsComm, &fileReaddirInp, rodsDirent);
    } else {
        rodsLog (LOG_ERROR,
                 "specCollReaddir: Unknown specColl collClass = %d",
                 specColl->collClass);
        status = SYS_UNKNOWN_SPEC_COLL_CLASS;
    }

    return (status);
}

int 
specCollClosedir (rsComm_t *rsComm, int specCollInx)
{
    fileClosedirInp_t fileClosedirInp;
    specColl_t *specColl;
    int status;
    dataObjInfo_t *dataObjInfo = SpecCollDesc[specCollInx].dataObjInfo;

    if (dataObjInfo == NULL || (specColl = dataObjInfo->specColl) == NULL) {
        return (SYS_INTERNAL_NULL_INPUT_ERR);
    }

    // =-=-=-=-=-=-=-
    // get the resc location of the hier leaf
    std::string location;
    eirods::error ret = eirods::get_loc_for_hier_string( dataObjInfo->rescHier, location );
    if( !ret.ok() ) {
        eirods::log( PASSMSG( "specCollClosedir - failed in get_loc_for_hier_string", ret ) );
        return -1;
    }

    if (getStructFileType (dataObjInfo->specColl) >= 0) {
        subStructFileFdOprInp_t subStructFileClosedirInp;
        memset (&subStructFileClosedirInp, 0, sizeof (subStructFileClosedirInp));
        subStructFileClosedirInp.type = dataObjInfo->specColl->type;
        subStructFileClosedirInp.fd = SpecCollDesc[specCollInx].l3descInx;
        rstrcpy (subStructFileClosedirInp.addr.hostAddr, 
                 location.c_str(), NAME_LEN);
        status = rsSubStructFileClosedir (rsComm, &subStructFileClosedirInp); 
    } else if (specColl->collClass == MOUNTED_COLL) {
        fileClosedirInp.fileInx = SpecCollDesc[specCollInx].l3descInx;
        status = rsFileClosedir (rsComm, &fileClosedirInp);
    } else {
        rodsLog (LOG_ERROR,
                 "specCollClosedir: Unknown specColl collClass = %d",
                 specColl->collClass);
        status = SYS_UNKNOWN_SPEC_COLL_CLASS;
    }

    return (status);
}

int 
l3Opendir (rsComm_t *rsComm, dataObjInfo_t *dataObjInfo)
{
    fileOpendirInp_t fileOpendirInp;
    int status;
    int rescTypeInx;

    if (dataObjInfo == NULL) return (SYS_INTERNAL_NULL_INPUT_ERR);

    // =-=-=-=-=-=-=-
    // get the resc location of the hier leaf
    std::string location;
    eirods::error ret = eirods::get_loc_for_hier_string( dataObjInfo->rescHier, location );
    if( !ret.ok() ) {
        eirods::log( PASSMSG( "l3Opendir - failed in get_loc_for_hier_string", ret ) );
        return -1;
    }

    if (getStructFileType (dataObjInfo->specColl) >= 0) {
        subFile_t subStructFileOpendirInp;
        status = 0;


        memset ( &subStructFileOpendirInp, 0, sizeof (subStructFileOpendirInp));
        rstrcpy( subStructFileOpendirInp.subFilePath, dataObjInfo->subPath, MAX_NAME_LEN );
        //rstrcpy( subStructFileOpendirInp.addr.hostAddr, dataObjInfo->rescInfo->rescLoc, NAME_LEN );
        rstrcpy( subStructFileOpendirInp.addr.hostAddr, location.c_str(), NAME_LEN );
        subStructFileOpendirInp.specColl = dataObjInfo->specColl;
        status = rsSubStructFileOpendir (rsComm, &subStructFileOpendirInp);
    } else {
#if 0 // JMC legacy resource 
        rescTypeInx = dataObjInfo->rescInfo->rescTypeInx;

        switch (RescTypeDef[rescTypeInx].rescCat) {
        case FILE_CAT:
#endif // JMC legacy resource 
            memset (&fileOpendirInp, 0, sizeof (fileOpendirInp));
            rstrcpy (fileOpendirInp.dirName, dataObjInfo->filePath, MAX_NAME_LEN);
            rstrcpy( fileOpendirInp.resc_name_, dataObjInfo->rescInfo->rescName, MAX_NAME_LEN );
            rstrcpy( fileOpendirInp.resc_hier_, dataObjInfo->rescHier, MAX_NAME_LEN );
            fileOpendirInp.fileType = static_cast< fileDriverType_t >( -1 );//RescTypeDef[rescTypeInx].driverType;
            rstrcpy (fileOpendirInp.addr.hostAddr, location.c_str(), NAME_LEN);

            status = rsFileOpendir (rsComm, &fileOpendirInp);
            if (status < 0) {
                rodsLog (LOG_ERROR,
                         "l3Opendir: rsFileOpendir for %s error, status = %d",
                         dataObjInfo->filePath, status);
            }
#if 0 // JMC legacy resource 
            break;
        default:
            rodsLog (LOG_NOTICE,
                     "l3Opendir: rescCat type %d is not recognized",
                     RescTypeDef[rescTypeInx].rescCat);
            status = SYS_INVALID_RESC_TYPE;
            break;
        }
#endif // JMC legacy resource 
    }
    return (status);
}

