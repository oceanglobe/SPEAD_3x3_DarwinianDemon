#!/bin/sh
##.............................................
##cp -pvf   ecco_darwin*/grid*.nc              GRID/
##.............................................
##cp -pvf   ecco_darwin*/grid*.nc              OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/ptr_tave*00000.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/ptracers*00000.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*00000.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*00000.t*.nc        OUTPUT/NET-CDF/
cp -pvf   data data.diagnostics              OUTPUT/NET-CDF/
##.............................................
##cp -pvf   ecco_darwin*/grid*.nc              OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/ptr_tave*25920.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/ptracers*25920.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*25920.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*25920.t*.nc        OUTPUT/NET-CDF/
##cp -pvf   data data.diagnostics              OUTPUT/NET-CDF/
##.............................................
##cp -pvf   ecco_darwin*/grid*.nc              OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/ptr_tave*11520.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*11520.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*11520.t*.nc        OUTPUT/NET-CDF/
##cp -pvf   data data.diagnostics              OUTPUT/NET-CDF/
##.............................................
##cp -pvf   ecco_darwin*/ptr_tave*08664.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*08664.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*08664.t*.nc        OUTPUT/NET-CDF/
##.............................................
##cp -pvf   ecco_darwin*/ptr_tave*11520.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*11520.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*11520.t*.nc        OUTPUT/NET-CDF/
##.............................................
##cp -pvf   ecco_darwin*/ptr_tave*14440.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*14440.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*14440.t*.nc        OUTPUT/NET-CDF/
##.............................................
##cp -pvf   ecco_darwin*/ptr_tave*20160.t*.nc  OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/TRAC*20160.t*.nc      OUTPUT/NET-CDF/
##cp -pvf   ecco_darwin*/PP*20160.t*.nc        OUTPUT/NET-CDF/
##.............................................
mv    STDOUT* STDERR*                    OUTPUT/NET-CDF/
mv    *.dat  *.txt                       OUTPUT/NET-CDF/
rm -f *.meta *.data 
##.............................................
