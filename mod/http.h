/***********************************************************************
 *  WC-NG - Cube 2: Sauerbraten Modification                           *
 *  Copyright (C) 2014, 2015 by Thomas Poechtrager                     *
 *  t.poechtrager@gmail.com                                            *
 *                                                                     *
 *  This program is free software; you can redistribute it and/or      *
 *  modify it under the terms of the GNU General Public License        *
 *  as published by the Free Software Foundation; either version 2     *
 *  of the License, or (at your option) any later version.             *
 *                                                                     *
 *  This program is distributed in the hope that it will be useful,    *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *
 *  GNU General Public License for more details.                       *
 *                                                                     *
 *  You should have received a copy of the GNU General Public License  *
 *  along with this program; if not, write to the Free Software        *
 *  Foundation, Inc.,                                                  *
 *  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.      *
 ***********************************************************************/

namespace mod {
namespace http
{
    enum
    {
        UNABLE_TO_PROCESS_REQUEST_NOW   =  0,
        INVALID_RESPONSE_CODE           = -1,
        QUERY_ABORTED                   = -2,
        QUERY_KILLED                    = -3,
        SSL_ERROR                       = -4,
        TIMEDOUT                        = -5
    };

    typedef void (*callback_t)(uint requestid, void *cbdata, bool ok, int responsecode, void *data, size_t datalen);
    typedef int (*contentcallback_t)(uint requestid, void *cbdata, void *data, size_t datalen);                            // must be thread safe
    typedef bool (*statuscallback_t)(uint requestid, void *cbdata, size_t totalsize, size_t downloaded, ullong mselapsed); // must be thread safe
    typedef void (*freecallbackdata_t)(void *data);

    struct header_t { string header; };

    struct request_t
    {
        strtool request;                                       /* Request URL */
        strtool referer;                                       /* Referer */
        vector<header_t> headers;                              /* Additional Headers */
        strtool useragent;                                     /* User Agent */

        strtool cacert;                                        /* CA Cert */

        int expecteddatalen                   = 100*1024;      /* Try to avoid re-allocs */
        int maxdatalen                        = 2*1024*1024;   /* Do not download more than this */
        bool nullterminatorneeded             = true;          /* Ensure the data is null terminated */

        long connecttimeout                   = 15L;
        long timeout                          = 0L;

        void *callbackdata                    = NULL;
        callback_t callback                   = NULL;
        contentcallback_t contentcallback     = NULL;
        statuscallback_t statuscallback       = NULL;
        freecallbackdata_t freedatacallback   = NULL;

        template<class URL>
        request_t(const URL &url) : request(url) {}
        request_t() {}
        ~request_t() { if (freedatacallback  && callbackdata) freedatacallback(callbackdata); }
    };

    static const uint WAIT_INFINITE = -1;

    void slice();
    void init();
    void deinit();
    time_t getfiletime(uint id);
    uint request(request_t *request);
    bool uninstallrequest(uint id, bool async = false, uint maxwait = WAIT_INFINITE);
} //namespace http
} //namespace mod
