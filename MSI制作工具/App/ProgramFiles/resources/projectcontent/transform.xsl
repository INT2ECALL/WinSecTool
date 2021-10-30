<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8"/>
  <xsl:template match="/">
    <html>
      <head>
        <style>
         * {
           -webkit-print-color-adjust: exact;
           -webkit-box-sizing: border-box;
           -moz-box-sizing: border-box;
           box-sizing: border-box;
         }
         *:before,
         *:after {
           -webkit-box-sizing: border-box;
           -moz-box-sizing: border-box;
           box-sizing: border-box;
         }

         body {
         max-width:1100px;
         margin: 0 auto;
         font-family: Arial, Helvetica, serif;
         color: #333;
         }

         /* Tables */
         .table {
         border-collapse: collapse!important
         }

         .table-bordered td,.table-bordered th {
         border: 1px solid #ddd!important
         }

         caption {
         padding-top: 8px;
         padding-bottom: 8px;
         color: #777;
         text-align: left
         }

         th {
         text-align: left
         }

         .table {
         width: 100%;
         max-width: 100%;
         margin-bottom: 20px
         }

         .table tr {
             page-break-inside: avoid;
         }

         .table>tbody>tr>td,.table>tbody>tr>th,.table>tfoot>tr>td,.table>tfoot>tr>th,.table>thead>tr>td,.table>thead>tr>th {
         padding: 8px;
         line-height: 1.42857143;
         vertical-align: top;
         border-top: 1px solid #ddd
         }

         .table>thead>tr>th {
         vertical-align: bottom;
         border-bottom: 2px solid #ddd
         }

         .table>caption+thead>tr:first-child>td,.table>caption+thead>tr:first-child>th,.table>colgroup+thead>tr:first-child>td,.table>colgroup+thead>tr:first-child>th,.table>thead:first-child>tr:first-child>td,.table>thead:first-child>tr:first-child>th {
         border-top: 0
         }

         .table>tbody+tbody {
         border-top: 2px solid #ddd
         }

         .table .table {
         background-color: #fff
         }

         .table-condensed>tbody>tr>td,.table-condensed>tbody>tr>th,.table-condensed>tfoot>tr>td,.table-condensed>tfoot>tr>th,.table-condensed>thead>tr>td,.table-condensed>thead>tr>th {
         padding: 5px
         }

         .table-bordered {
         border: 1px solid #ddd
         }

         .table-bordered>tbody>tr>td,.table-bordered>tbody>tr>th,.table-bordered>tfoot>tr>td,.table-bordered>tfoot>tr>th,.table-bordered>thead>tr>td,.table-bordered>thead>tr>th {
         border: 1px solid #ddd
         }

         .table-bordered>thead>tr>td,.table-bordered>thead>tr>th {
         border-bottom-width: 2px
         }

         .table-striped>tbody>tr:nth-of-type(odd) {
         background-color: #f9f9f9
         }

         .table-hover>tbody>tr:hover {
         background-color: #f5f5f5
         }

         /* Typography */
         .h1,.h2,.h3,.h4,.h5,.h6,h1,h2,h3,h4,h5,h6 {
         font-family: inherit;
         font-weight: 500;
         line-height: 1.1;
         color: inherit
         }

         .h1 .small,.h1 small,.h2 .small,.h2 small,.h3 .small,.h3 small,.h4 .small,.h4 small,.h5 .small,.h5 small,.h6 .small,.h6 small,h1 .small,h1 small,h2 .small,h2 small,h3 .small,h3 small,h4 .small,h4 small,h5 .small,h5 small,h6 .small,h6 small {
         font-weight: 400;
         line-height: 1;
         color: #777
         }

         h1,h2,h3 {
         margin-top: 20px;
         margin-bottom: 10px
         }

         .h1 .small,.h1 small,.h2 .small,.h2 small,.h3 .small,.h3 small,h1 .small,h1 small,h2 .small,h2 small,h3 .small,h3 small {
         font-size: 65%
         }

         h4,h5,h6 {
         margin-top: 10px;
         margin-bottom: 10px
         }

         .h4 .small,.h4 small,.h5 .small,.h5 small,.h6 .small,.h6 small,h4 .small,h4 small,h5 .small,h5 small,h6 .small,h6 small {
         font-size: 75%
         }

         .h1,h1 {
         font-size: 36px
         }

         .h2,h2 {
         font-size: 30px
         }

         .h3,h3 {
         font-size: 24px
         }

         .h4,h4 {
         font-size: 18px
         }

         .h5,h5 {
         font-size: 14px
         }

         .h6,h6 {
         font-size: 12px
         }


         /* Grid */
         .row {
           margin-left: -15px;
           margin-right: -15px;
         }
         .col-xs-1, .col-sm-1, .col-md-1, .col-lg-1, .col-xs-2, .col-sm-2, .col-md-2, .col-lg-2, .col-xs-3, .col-sm-3, .col-md-3, .col-lg-3, .col-xs-4, .col-sm-4, .col-md-4, .col-lg-4, .col-xs-5, .col-sm-5, .col-md-5, .col-lg-5, .col-xs-6, .col-sm-6, .col-md-6, .col-lg-6, .col-xs-7, .col-sm-7, .col-md-7, .col-lg-7, .col-xs-8, .col-sm-8, .col-md-8, .col-lg-8, .col-xs-9, .col-sm-9, .col-md-9, .col-lg-9, .col-xs-10, .col-sm-10, .col-md-10, .col-lg-10, .col-xs-11, .col-sm-11, .col-md-11, .col-lg-11, .col-xs-12, .col-sm-12, .col-md-12, .col-lg-12 {
           position: relative;
           min-height: 1px;
           padding-left: 15px;
           padding-right: 15px;
           page-break-inside: avoid !important;
         }
         .col-xs-1, .col-xs-2, .col-xs-3, .col-xs-4, .col-xs-5, .col-xs-6, .col-xs-7, .col-xs-8, .col-xs-9, .col-xs-10, .col-xs-11, .col-xs-12 {
           float: left;
         }
         .col-xs-12 {
           width: 100%;
         }
         .col-xs-11 {
           width: 91.66666667%;
         }
         .col-xs-10 {
           width: 83.33333333%;
         }
         .col-xs-9 {
           width: 75%;
         }
         .col-xs-8 {
           width: 66.66666667%;
         }
         .col-xs-7 {
           width: 58.33333333%;
         }
         .col-xs-6 {
           width: 50%;
         }
         .col-xs-5 {
           width: 41.66666667%;
         }
         .col-xs-4 {
           width: 33.33333333%;
         }
         .col-xs-3 {
           width: 25%;
         }
         .col-xs-2 {
           width: 16.66666667%;
         }
         .col-xs-1 {
           width: 8.33333333%;
         }
         .col-xs-pull-12 {
           right: 100%;
         }
         .col-xs-pull-11 {
           right: 91.66666667%;
         }
         .col-xs-pull-10 {
           right: 83.33333333%;
         }
         .col-xs-pull-9 {
           right: 75%;
         }
         .col-xs-pull-8 {
           right: 66.66666667%;
         }
         .col-xs-pull-7 {
           right: 58.33333333%;
         }
         .col-xs-pull-6 {
           right: 50%;
         }
         .col-xs-pull-5 {
           right: 41.66666667%;
         }
         .col-xs-pull-4 {
           right: 33.33333333%;
         }
         .col-xs-pull-3 {
           right: 25%;
         }
         .col-xs-pull-2 {
           right: 16.66666667%;
         }
         .col-xs-pull-1 {
           right: 8.33333333%;
         }
         .col-xs-pull-0 {
           right: auto;
         }
         .col-xs-push-12 {
           left: 100%;
         }
         .col-xs-push-11 {
           left: 91.66666667%;
         }
         .col-xs-push-10 {
           left: 83.33333333%;
         }
         .col-xs-push-9 {
           left: 75%;
         }
         .col-xs-push-8 {
           left: 66.66666667%;
         }
         .col-xs-push-7 {
           left: 58.33333333%;
         }
         .col-xs-push-6 {
           left: 50%;
         }
         .col-xs-push-5 {
           left: 41.66666667%;
         }
         .col-xs-push-4 {
           left: 33.33333333%;
         }
         .col-xs-push-3 {
           left: 25%;
         }
         .col-xs-push-2 {
           left: 16.66666667%;
         }
         .col-xs-push-1 {
           left: 8.33333333%;
         }
         .col-xs-push-0 {
           left: auto;
         }
         .col-xs-offset-12 {
           margin-left: 100%;
         }
         .col-xs-offset-11 {
           margin-left: 91.66666667%;
         }
         .col-xs-offset-10 {
           margin-left: 83.33333333%;
         }
         .col-xs-offset-9 {
           margin-left: 75%;
         }
         .col-xs-offset-8 {
           margin-left: 66.66666667%;
         }
         .col-xs-offset-7 {
           margin-left: 58.33333333%;
         }
         .col-xs-offset-6 {
           margin-left: 50%;
         }
         .col-xs-offset-5 {
           margin-left: 41.66666667%;
         }
         .col-xs-offset-4 {
           margin-left: 33.33333333%;
         }
         .col-xs-offset-3 {
           margin-left: 25%;
         }
         .col-xs-offset-2 {
           margin-left: 16.66666667%;
         }
         .col-xs-offset-1 {
           margin-left: 8.33333333%;
         }
         .col-xs-offset-0 {
           margin-left: 0%;
         }
         @media (min-width: 768px) {
           .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .col-sm-6, .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .col-sm-11, .col-sm-12 {
         float: left;
           }
           .col-sm-12 {
         width: 100%;
           }
           .col-sm-11 {
         width: 91.66666667%;
           }
           .col-sm-10 {
         width: 83.33333333%;
           }
           .col-sm-9 {
         width: 75%;
           }
           .col-sm-8 {
         width: 66.66666667%;
           }
           .col-sm-7 {
         width: 58.33333333%;
           }
           .col-sm-6 {
         width: 50%;
           }
           .col-sm-5 {
         width: 41.66666667%;
           }
           .col-sm-4 {
         width: 33.33333333%;
           }
           .col-sm-3 {
         width: 25%;
           }
           .col-sm-2 {
         width: 16.66666667%;
           }
           .col-sm-1 {
         width: 8.33333333%;
           }
           .col-sm-pull-12 {
         right: 100%;
           }
           .col-sm-pull-11 {
         right: 91.66666667%;
           }
           .col-sm-pull-10 {
         right: 83.33333333%;
           }
           .col-sm-pull-9 {
         right: 75%;
           }
           .col-sm-pull-8 {
         right: 66.66666667%;
           }
           .col-sm-pull-7 {
         right: 58.33333333%;
           }
           .col-sm-pull-6 {
         right: 50%;
           }
           .col-sm-pull-5 {
         right: 41.66666667%;
           }
           .col-sm-pull-4 {
         right: 33.33333333%;
           }
           .col-sm-pull-3 {
         right: 25%;
           }
           .col-sm-pull-2 {
         right: 16.66666667%;
           }
           .col-sm-pull-1 {
         right: 8.33333333%;
           }
           .col-sm-pull-0 {
         right: auto;
           }
           .col-sm-push-12 {
         left: 100%;
           }
           .col-sm-push-11 {
         left: 91.66666667%;
           }
           .col-sm-push-10 {
         left: 83.33333333%;
           }
           .col-sm-push-9 {
         left: 75%;
           }
           .col-sm-push-8 {
         left: 66.66666667%;
           }
           .col-sm-push-7 {
         left: 58.33333333%;
           }
           .col-sm-push-6 {
         left: 50%;
           }
           .col-sm-push-5 {
         left: 41.66666667%;
           }
           .col-sm-push-4 {
         left: 33.33333333%;
           }
           .col-sm-push-3 {
         left: 25%;
           }
           .col-sm-push-2 {
         left: 16.66666667%;
           }
           .col-sm-push-1 {
         left: 8.33333333%;
           }
           .col-sm-push-0 {
         left: auto;
           }
           .col-sm-offset-12 {
         margin-left: 100%;
           }
           .col-sm-offset-11 {
         margin-left: 91.66666667%;
           }
           .col-sm-offset-10 {
         margin-left: 83.33333333%;
           }
           .col-sm-offset-9 {
         margin-left: 75%;
           }
           .col-sm-offset-8 {
         margin-left: 66.66666667%;
           }
           .col-sm-offset-7 {
         margin-left: 58.33333333%;
           }
           .col-sm-offset-6 {
         margin-left: 50%;
           }
           .col-sm-offset-5 {
         margin-left: 41.66666667%;
           }
           .col-sm-offset-4 {
         margin-left: 33.33333333%;
           }
           .col-sm-offset-3 {
         margin-left: 25%;
           }
           .col-sm-offset-2 {
         margin-left: 16.66666667%;
           }
           .col-sm-offset-1 {
         margin-left: 8.33333333%;
           }
           .col-sm-offset-0 {
         margin-left: 0%;
           }
         }
         @media (min-width: 992px) {
           .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .col-md-12 {
         float: left;
           }
           .col-md-12 {
         width: 100%;
           }
           .col-md-11 {
         width: 91.66666667%;
           }
           .col-md-10 {
         width: 83.33333333%;
           }
           .col-md-9 {
         width: 75%;
           }
           .col-md-8 {
         width: 66.66666667%;
           }
           .col-md-7 {
         width: 58.33333333%;
           }
           .col-md-6 {
         width: 50%;
           }
           .col-md-5 {
         width: 41.66666667%;
           }
           .col-md-4 {
         width: 33.33333333%;
           }
           .col-md-3 {
         width: 25%;
           }
           .col-md-2 {
         width: 16.66666667%;
           }
           .col-md-1 {
         width: 8.33333333%;
           }
           .col-md-pull-12 {
         right: 100%;
           }
           .col-md-pull-11 {
         right: 91.66666667%;
           }
           .col-md-pull-10 {
         right: 83.33333333%;
           }
           .col-md-pull-9 {
         right: 75%;
           }
           .col-md-pull-8 {
         right: 66.66666667%;
           }
           .col-md-pull-7 {
         right: 58.33333333%;
           }
           .col-md-pull-6 {
         right: 50%;
           }
           .col-md-pull-5 {
         right: 41.66666667%;
           }
           .col-md-pull-4 {
         right: 33.33333333%;
           }
           .col-md-pull-3 {
         right: 25%;
           }
           .col-md-pull-2 {
         right: 16.66666667%;
           }
           .col-md-pull-1 {
         right: 8.33333333%;
           }
           .col-md-pull-0 {
         right: auto;
           }
           .col-md-push-12 {
         left: 100%;
           }
           .col-md-push-11 {
         left: 91.66666667%;
           }
           .col-md-push-10 {
         left: 83.33333333%;
           }
           .col-md-push-9 {
         left: 75%;
           }
           .col-md-push-8 {
         left: 66.66666667%;
           }
           .col-md-push-7 {
         left: 58.33333333%;
           }
           .col-md-push-6 {
         left: 50%;
           }
           .col-md-push-5 {
         left: 41.66666667%;
           }
           .col-md-push-4 {
         left: 33.33333333%;
           }
           .col-md-push-3 {
         left: 25%;
           }
           .col-md-push-2 {
         left: 16.66666667%;
           }
           .col-md-push-1 {
         left: 8.33333333%;
           }
           .col-md-push-0 {
         left: auto;
           }
           .col-md-offset-12 {
         margin-left: 100%;
           }
           .col-md-offset-11 {
         margin-left: 91.66666667%;
           }
           .col-md-offset-10 {
         margin-left: 83.33333333%;
           }
           .col-md-offset-9 {
         margin-left: 75%;
           }
           .col-md-offset-8 {
         margin-left: 66.66666667%;
           }
           .col-md-offset-7 {
         margin-left: 58.33333333%;
           }
           .col-md-offset-6 {
         margin-left: 50%;
           }
           .col-md-offset-5 {
         margin-left: 41.66666667%;
           }
           .col-md-offset-4 {
         margin-left: 33.33333333%;
           }
           .col-md-offset-3 {
         margin-left: 25%;
           }
           .col-md-offset-2 {
         margin-left: 16.66666667%;
           }
           .col-md-offset-1 {
         margin-left: 8.33333333%;
           }
           .col-md-offset-0 {
         margin-left: 0%;
           }
         }
         @media (min-width: 1200px) {
           .col-lg-1, .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-5, .col-lg-6, .col-lg-7, .col-lg-8, .col-lg-9, .col-lg-10, .col-lg-11, .col-lg-12 {
         float: left;
           }
           .col-lg-12 {
         width: 100%;
           }
           .col-lg-11 {
         width: 91.66666667%;
           }
           .col-lg-10 {
         width: 83.33333333%;
           }
           .col-lg-9 {
         width: 75%;
           }
           .col-lg-8 {
         width: 66.66666667%;
           }
           .col-lg-7 {
         width: 58.33333333%;
           }
           .col-lg-6 {
         width: 50%;
           }
           .col-lg-5 {
         width: 41.66666667%;
           }
           .col-lg-4 {
         width: 33.33333333%;
           }
           .col-lg-3 {
         width: 25%;
           }
           .col-lg-2 {
         width: 16.66666667%;
           }
           .col-lg-1 {
         width: 8.33333333%;
           }
           .col-lg-pull-12 {
         right: 100%;
           }
           .col-lg-pull-11 {
         right: 91.66666667%;
           }
           .col-lg-pull-10 {
         right: 83.33333333%;
           }
           .col-lg-pull-9 {
         right: 75%;
           }
           .col-lg-pull-8 {
         right: 66.66666667%;
           }
           .col-lg-pull-7 {
         right: 58.33333333%;
           }
           .col-lg-pull-6 {
         right: 50%;
           }
           .col-lg-pull-5 {
         right: 41.66666667%;
           }
           .col-lg-pull-4 {
         right: 33.33333333%;
           }
           .col-lg-pull-3 {
         right: 25%;
           }
           .col-lg-pull-2 {
         right: 16.66666667%;
           }
           .col-lg-pull-1 {
         right: 8.33333333%;
           }
           .col-lg-pull-0 {
         right: auto;
           }
           .col-lg-push-12 {
         left: 100%;
           }
           .col-lg-push-11 {
         left: 91.66666667%;
           }
           .col-lg-push-10 {
         left: 83.33333333%;
           }
           .col-lg-push-9 {
         left: 75%;
           }
           .col-lg-push-8 {
         left: 66.66666667%;
           }
           .col-lg-push-7 {
         left: 58.33333333%;
           }
           .col-lg-push-6 {
         left: 50%;
           }
           .col-lg-push-5 {
         left: 41.66666667%;
           }
           .col-lg-push-4 {
         left: 33.33333333%;
           }
           .col-lg-push-3 {
         left: 25%;
           }
           .col-lg-push-2 {
         left: 16.66666667%;
           }
           .col-lg-push-1 {
         left: 8.33333333%;
           }
           .col-lg-push-0 {
         left: auto;
           }
           .col-lg-offset-12 {
         margin-left: 100%;
           }
           .col-lg-offset-11 {
         margin-left: 91.66666667%;
           }
           .col-lg-offset-10 {
         margin-left: 83.33333333%;
           }
           .col-lg-offset-9 {
         margin-left: 75%;
           }
           .col-lg-offset-8 {
         margin-left: 66.66666667%;
           }
           .col-lg-offset-7 {
         margin-left: 58.33333333%;
           }
           .col-lg-offset-6 {
         margin-left: 50%;
           }
           .col-lg-offset-5 {
         margin-left: 41.66666667%;
           }
           .col-lg-offset-4 {
         margin-left: 33.33333333%;
           }
           .col-lg-offset-3 {
         margin-left: 25%;
           }
           .col-lg-offset-2 {
         margin-left: 16.66666667%;
           }
           .col-lg-offset-1 {
         margin-left: 8.33333333%;
           }
           .col-lg-offset-0 {
         margin-left: 0%;
           }
         }

         .row:before,
         .row:after {
           content: " ";
           display: table;
         }

         .row:after {
           clear: both;
         }

         /* Well */
         .well {
         height: 127px;
         padding: 5px;
         margin-bottom: 30px;
         background-color: #dddde1;
         border-radius: 4px;
         }

         .well-lg {
         padding: 24px;
         border-radius: 6px
         }

         .well-sm {
         padding: 9px;
         border-radius: 3px
         }

         /* Text helpers */
         .text-left {
         text-align: left
         }

         .text-right {
         text-align: right
         }

         .text-center {
         text-align: center
         }

         .text-justify {
         text-align: justify
         }

         .text-nowrap {
         white-space: nowrap
         }

         .text-lowercase {
         text-transform: lowercase
         }

         .text-uppercase {
         text-transform: uppercase
         }

         .text-capitalize {
         text-transform: capitalize
         }

         .text-muted {
         color: #777
         }

         /* Quick link */
         .quick-link {
         text-decoration: none;
         }

         .quick-link__value {
         color: #fff;
         padding-bottom: 5px
         }

         .quick-link__description {
         color: #333;
         }

         /* IMG */

         .heightSet {
             max-height: 50px;
         }

         /* PAGE */

         p {
             page-break-after: always; 
         }

         .footer {
             position: fixed; 
             bottom: 0px; 
         }

         .pagenum:before {
             content: counter(page);
         }
        </style>
      </head>
      <body>

        <br/>
        <div align="right">
          <a href="http://www.advancedinstaller.com">
          <svg
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:cc="http://creativecommons.org/ns#"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:svg="http://www.w3.org/2000/svg"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            viewBox="0 0 375 64"
            width="375"
            height="64"
            version="1.1"
            id="svg_logo">
            <metadata id="metadata">
              <rdf:RDF>
                <cc:Work rdf:about="">
                  <dc:format>image/svg+xml</dc:format>
                  <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"/>
                </cc:Work>
              </rdf:RDF>
            </metadata>
            <image
              x="0"
              y="0"
              width="375" 
              height="64"
              style="image-rendering:optimizeQuality"
              xlink:href="data:image/png;base64,
                          iVBORw0KGgoAAAANSUhEUgAAAfYAAACCCAMAAACD8RrtAAAAw1BMVEUAAAAkJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsb
						  P1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8k
						  JCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aLCzsbP1ih8kJCg8aL
						  CzsbP1ih9KO95YAAAAPXRSTlMAEBAQECAgICAwMDAwQEBAQFBQUFBgYGBgcHBwcICAgICPj4+Pn5+fn6+vr6+/v7+/z8/Pz9/f39/v
						  7+/vJVNuPQAAEQVJREFUeAHsnHFPpDoXh0+mRiZithPHiBFjjWzEyESMGDHDBOb7f6rXFXHbXw+IfTu6d5fnL3Nvp8Py0J7TnjI08R
						  cxMTExMTExMTExsXr8ebxHE/8Ym+0Lj5cLmviHONx23E/q/x3Otxqb1fkh/QNMrLbAZnU6p3+BKbQjzzd/tfqJxbaP5783wZ+43A7x
						  srajbyNWb9B4AvjIX4FqkeSP+z7j357gB01HSKORTQv9TTQtivyxHcX9NyT4SdOREjJp9x/akW9a25VNR0XApH2nof2rE3wU2LH0q3
						  3S/ohmx6j/kgQ/1bSnXrVP2ve2TjzS7qkaDeFT+6T92E37MxHNTma0Q5aNTuRT+6T9p5v2GyI6quvrI9oZWaOTEzJp331oR46J6Kp+
						  4elsR0NeNC2d/YBo0v7loR3YI6KH+pX1xU7ER01Lpz/2p33Sfuqe0e3XHTsRn78N9u6Pwp/2SfuNm/afRHRS/+bpaFcbsxHFH2/Qhl
						  IGPrQHUsqQPkRqX9d3PdKlD7yWnWl/dg/t17XO3T55pZMt3h+AhFiCpHibDpIAtQeyJbBuaYvQ/lOclU1LmUXCstj1Eqi3r8tjQQwi
						  eu8nj3vELtMSWtidvF1KutyF9rl7aKen2mB9Qj4pujn+/c+SlZ42Gnloao96lgEpbgbIvDFJBcab9qYrrU2lbF+qanRySRZRaXwRI9
						  7opIxQ+zeHduTWY4QPuzleG/iSGTcV6IoM7QI2e2AjKOtkZY1FFTHaRdEYZNCvxMux56ggxy+K8dEpGvwW1P5Nof2yDe3I04H34pvQ
						  wnzKZftIbMT2zmfEZn2RcZ+RyNJuN8zsy0EKQRph1VikZLeALlD794T2BYR2/xN9qd/WoqcMt2wYEl17BHrwmdK7t5CoPW8sYrTOe0
						  en/d5F2dhkfrUfbt2gF9Y1xxl5AMdjzJfhgqoZwNjzqfqfKVJNDyVo54RUwrrmgXle9FyxwoCC+NV+7mb9nogOap5r8gDkXAGOWbxD
						  ZSJfSAwv5g7vkl0bGvG/KZV8YZm8u1kyKopYShnleihApVWylFLGJTtttJSvvaTYwpgx0mX3Tb61r0abXl0uFucrLbSf1Tv0jjlXwW
						  Vm0r4bsaU9YjKr2OgttuZrkcKHcjv/irToDpNGIvBqujZL7CUsuofJOlmSB9QiS+/aN2Olz9+2ctsU8JCIbusdel/CUFJcZpbBgINo
						  b+7sl/YHM9NpZM8jOWqvQkLLFQ527moCw2kV2ll7BE9Tymb26ktD+6m54ttAaEeuvBXfBCznCn2qhnuB4x260m61eae5pf2yR3tMdp
						  iGxyDlcsfIcLpk8pPSvNqCz2HUV4b2U1jprzC0Iye+im+Ec19g581lT8CHEaesMShgg0BD8tpL7tGU5kgW3A5zas8yOGuERp4hsY1P
						  7fejF+k0O7u9a0us54/nRHRRD3Hkp/gWWcMmtm97BPEBtFOF4yc17n6Yt4QjtEfgQjPE7CBjtBCaYHvWSPSLzwnb+NQ++hwNHbzO6e
						  sD6rir+4CGLuTW2A5hvGnDi4AKtKfYWYkObRSvPYBHQ9PeUy+K8hbtYS74RUuBOQy28aZ9MW6Kb623Omf0Rj3Mw4zcCZgAV1q3FQMB
						  3iIc/jE8QeLj2Qa0V9SvPcUmNgm/Wxtp15vjtWGk+rqj0nv62L6llh814jGti3VRMMsneNdV36f7FoMKHhcgkKpoeO15r3ZogmBBp7
						  efAp93SHbUl4X2e7Pq8nR9so+h3Xd4L3BOxVke7xZ7G/vKbUXPHC9kpPL2fzporz720uXsuUmh9cOtBrD7rwntN3rVpVN/9FD3g/HA
						  tfhWKR3cOZN2MAXt/CZAwM2jIuoq4K7aRwzHZhiFvXAzxZcdlb4cMbb97tokzRApJNK9t9caKqkeSjO7SO5De/zna//pdHxqPD/ci2
						  8DVOKT2iHdyqw5PrS/sHTVLv987Y/b8bHdhTv34tsQkTl1964D7Dx4qQ190VsLLbI4UK7aI3ftsYt2/0elIZN34MS9+DZAZt71YMTJ
						  WW1HZKl1gvXtIoll253aYWzPFU8w1EvpTftxz++WXF5e3jzDun321OZyF5/y/+RefBtCDGfyka09/b0KSHBUKjzU5ku7SzZe8pk8du
						  87tN8vqGVx//tB2Pvl/eqpfrh4XbGjes/Dfdl8RGwsZeO+jJDpMyQqcY4v2Y1XX+t2qVpGTtT4SgC3SeH/PNW5Phls9CWcwexuB8Md
						  t9oTiUB1CnZhrFU/O9AC+BAUS9y1dxfH/2tybc7JR54g1Im9aZ9/UGmjww08DR1wVNrvno1oMGb3Va9xIxM8Nuy+d4xDm48Vyae1c+
						  e+YO0Y8Rcs5Csh1qB0Cm/aT/lKGx1dXFwcQTV+tdc9K4f0qcT+1rn4VgxEfcWPAMgIOUVBjnc+Zkdp/mntIVsikLrGgHcaa51jNQIX
						  N8r/UenNL7cHb7nbkblnv7k5ntP8eIVHpT9k37X4Fg/k+KW5mSdwi6+FzYTRDb/8D5pPa8dakV26w9c8YCUR601g0sj9aX/m9mX213
						  o2ttf7FtRoLlx/kiwYyvZC4xZl/KsF3Kxd4XjjJ+fMQbvC49F2+TzGcpL+ucBoUgXYxI/2+Qdn39f7/AlLDO2+kjqwUAyu7RL73Bla
						  B+0hLgE7pG1LpHhielg7HIVIhbURFEGTmKnxQpMiwCZetJ+yQtfmOD3///fsDtyKb/HgTk4Fu7iFtA+ZNv07vhmXQpYR84qaGK+dFF
						  5NXGHVUOGx2CBtsBd8GSvIGo/aV6x22FpdsGnfj3U9njOn4lsTDK/pl7jELxKloIjWX9+J+MP2VaaUyqpGI1cqGKtdlObVVMyPqxVG
						  E+0tm4R5gaJKlVKF39cjbjZodE5ED2YSvmAjAc0+EdwfnIpvxQc7eOnAPm7Fag9hjocptB85Vru1uY8xaKBJIaBbxN/m7OLy3lq1n5
						  jD9HKLUMvR+AE/cym+xYP79cNvr8GSDLu2363xpZ2iYaW8d0zg2F5y5Ul7p/5RD9vacH+YcTW6Fb1xsJMdG4lzPBLBPC1yZmzx2hOY
						  4/U0EKmiwkU7Lat+6+gdmwx5L4Xy/nOExz/f7B4S0ZVufT6weztb72AJl+Icjwj2FSSdhHq0h9wczz87eUCRk3Z8eR1F8e/SJ3hBsr
						  QeC0/aTw4M9ac3z8aPT133nLU7pHcO1v6r7rjAscms+SBI8ccjUDvM8tkHvy+RvXpMnbTjz2KkAdlIXXzFNRFKu6BSEfnSvq7Xt2eG
						  +vkxEc30PMyO7BvSOKtHsaZdI5ZJnldVnsUhuRKqPG+qPFdL8S4nb4rc4Yf7gyht+0q6vixE9OuKG/3r7AvK8rL51Ql5o9O7/nUMVq
						  NL6a56CrMr0rnzn9NN7JQfcAK647o7Bcf/vMk5dLLLI3X+mTiBxfXV0UyvqMKevRbaHYb7Cf0JTOAJ6E79D9rXsrAuwdd4xofHKZWf
						  +H7toN4UtQfqbzBD+G9pn7gdHY3nr2u7lv+1d4atrdtQGD4quOAyB1xwmMsccMGFlKuAy1xQmP7/39rKFnOcN9WbuEqubufnywWH+i
						  p6pIN0Kp3+LjIjyr/Kz6BoOmu9s3bblEYWuK+Pvd29TNT/+OuQtZ/wHHnjbkcOTyp7oBOgPXzWypS8c17T19p8ZQnwyq090ISbnQsA
						  jbWVfEpuGRX7DjjMuXZY4I/89sePP+WYTWTtfuTwpPEjJXa3/w8rmsx6wDVG1Ds5+pWlek+42YUA0FjfBGKUZzTnfIcuJ9q/lk1/vK
						  X2wRDtYauumK29U8+rJLUDrZmtfSWM1S21Y3fZoCOgmqvdqefbNLUDvZmrfSOMzU21u4xoB+vgfZb20mtMotrR+zfR7juuvfUhilna
						  t15TJa4d4lL8ndfuttp9wbSTbhvmaDe0N9PU7st503QvjH3kdA3T3jPt1it621jrvKaeob3yU8yvon04SzvywFd0t9Xuq7D2HHdskn
						  e6J2Zot35KnZZ2ZxVkuj9FKUPyEvvsLNXuTFB76w+4XEZyNeM/HheNxo90jWIcYBmslW6ifWhOUxz3ixVNqc138+YpqTp0H/0Xr1S7
						  b4La7emwUODPn++s9sdkt9BuJQhqF9zKDDONPfPJzrmPqd1nIe2QTIOusBdr70F7nbR2GbAXRyLcaXk48x0SVbvl2rEvyvnaMw/0aW
						  uvcI7g1mteDdGxrglnF1e7L2ZoxxdTZ5AIcDX2ZpLas0BznuddUIeBw3mOrH2YEeTFXawdQmaX+QNtutpJc9ZfLSr4Eqd+DdcO1Ew7
						  6dqLnOVqN9TjyEtcuwms6Qi7O0Hu3iIXNuDaHW7iQLvzI9sshnYV4/WaPv9FtAvwfra3Pe7AHvexL7hz7Q1uR0H71iu2lfm6dqf+0x
						  yjfILaVTN7EqQJu6n41SXF6Z5jaZcBJhtor/2UbZ19TXs5yXgNGOVT0g6d0JITEpS38QbNwxOP75rHaNpxFwbajcMVYFua+do7FeN1
						  ErD8SVm6ims3Q7A1EKcZuw/gKWEv0bSrjitBe/AEhW3yi7VjjNfhs7ua9jCWajdb3PPwKB+bl4ja8+PzVajd9P40Q2NmaK/0QNNR3i
						  WqPasGr9uMrG6ifRVRuwqyzSfaJXP+ExyI5862WjNG+SS0IxiR+Fo+Lu8SU7sZnboMtMN8B4biQu1Gd+HUSpemdm5dnm6g/SmqdrVI
						  7c4/OTv/2GsFkxuTB6lqbwXh9SjisL+Lq13UKjVwTr4j3ql2MGXgV3lV0tptzg9AXo+NxNWuuqUH7Yqs7v1p8gu0Z3h+rsRHac72zg
						  if7mlMdq5d5+Eq1D41P34692hMDVNbp39N2kHe5T9tum8kuvZMn6+aagdM2faBME+d9VoxRvkEsnQhnGHTPYHJzrXDgxa1I1m1xfPO
						  XDvGeIzyiWrHBgJP6SzjuXbIv2YB7QrTOK84W3vrw2Tp5eSzqsd1jCBvV7T+JnG1w67KEu0jpvNghjsbiPY6Le14grIj5+Guw0Ns7d
						  B/bvrVq+ZAFoiJ1Znac0/ok9QukJO/7apuI1fSXny2wO0CvT9ApzNnnWdkSWrPoIG3DPNvElk7CAHtTSAr01ys3XlGnaR26UlroIZo
						  RPYP19OeOaYdM5PlpdpLT+lT0k5GOLC+iva1XE+7NKh9asoFuqk8T3vnOXlS2skIx7PT8XmWa2qX4aT2jBS+UK6oduM8p01KO76jI9
						  XKYvMq19VeonY9GlBuAYGAaK8w64EfDUlqF/IOOP0ci7e7K2sXi9qnwd/VoijdJVk6yP1PMTC48NLslKMm28+vsuJZOiCadvQe33pk
						  7flJ7dnkWXXy8m9JtINaTG33x1HeE0btIRqtPUA87eg9vvW42qUF7fjU223TbC1epeLaq9BZ81q/LUHtlmvn3uNbj6HduFPazeAJBd
						  EOE7oOXoItk9buhXtPwDrVrqhROwZ/oBWuHTJdgSjfpa+d8HL9A9IxtcvA6gsBvJYgjqk+vIx2CWpXn+XC2cRPxF9Te3FSuxSOnDSi
						  2gMxHmNKmbT2Sjj8j3jOuCR5Pe26H22o0DAopNrzcIzXkaZLUDvJ1wB3O+KVXom+pfZMa9dUgz9Bl8m52tvPYzzsGEx62g3mpghP+/
						  lT/Um+AK8nL0ANxd8PlJ07vgCppNNi8B0r/Z5Pf8gSVD15Uig+txTVL/Ddof2lnMf969x87L0kRdF0tv+3Wl9bZbJAWM3Zyr2t5Bdn
						  Yf1+ofT3tSx8B/G7S1Zy30b6wsPL/ryF3MuDfCMW7tavfB23vpOFb2f+8RnWd/gHQhe+o/rV5nV3ZHz3uln9H5QvrP5hvVl//COpsL
						  CwsLCwsPA3Qugyy7XFDQEAAAAASUVORK5CYII="/>
          </svg>
          </a>
        </div>
        <br/><br/><br/><br/><br/><br/>

        <xsl:variable name="productName">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Product Name'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="moduleName">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Module Name'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="productVersion">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Product Version'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="moduleVersion">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Module Version'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="buildName">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Build Name'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="companyName">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Company Name'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="language">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Language'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="comments">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="*[1]='Comments'">
              <xsl:value-of select="*[2]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$productName=''">
            <div class="text-left h2">
              Report for <xsl:value-of select='$moduleName'/>
            </div>
            <div class="text-left h2">
              version <xsl:value-of select='$moduleVersion'/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="text-left h2">
              Report for <xsl:value-of select='$productName'/>
            </div>
            <div class="text-left h2">
              version <xsl:value-of select='$productVersion'/>, <xsl:value-of select='$buildName'/> build
            </div>
          </xsl:otherwise>
        </xsl:choose>
        <br/><br/>
        
        <div class="text-left h4">
          The report details the content of
          <xsl:choose>
            <xsl:when test="$productName=''">
              <xsl:value-of select='$moduleName'/>,
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='$productName'/>,
            </xsl:otherwise>
          </xsl:choose>
          a property of <xsl:value-of select='$companyName'/>. The language of this product is <xsl:value-of select='$language'/>.
        </div>
        <br/>

        <div class="text-left h4">
          <xsl:if test="$comments != ''">
            <xsl:value-of select='$comments'/>
            <br/>
          </xsl:if>
        </div>
        <br/>

        <h3>Package Content</h3>
        <div class="row">
          <xsl:for-each select="report/tables/table">
            <xsl:if test="position() != 1">
              <div class="col-xs-2">
                <a href="#{position()}" style="display:block;position:absolute; width:100%; height:100%; top:0; left: 0; z-index: 10;">
                  <div class="well">
                    <div class="text-right h1">
                      <div class="quick-link__value">
                        <a style="color:white; text-decoration:none" href="#{position()}">
                          <xsl:value-of select="@count"/>
                        </a>
                      </div>
                    </div>
                    <div class="text-left text-uppercase h5">
                      <div class="quick-link__description">
                        <a style="color:black; text-decoration:none" href="#{position()}">
                          <xsl:value-of select="@name"/>
                        </a>
                      </div>
                    </div>
                  </div>
                </a>
              </div>
            </xsl:if>
          </xsl:for-each>
        </div>

        <p>
          <!-- pagebreak -->
        </p>

        <xsl:for-each select="report/tables/table">
          <h3 id="{position()}" style="page-break-inside: avoid !important">
            <xsl:value-of select="@name"/> (<xsl:value-of select="@count"/>)
          </h3>
          <table class="table table-striped table-bordered" align="center" style="border-collapse:collapse; table-layout:fixed">
            <colgroup>
              <xsl:for-each select="columns/column">
                <col style="width: {@width}%"/>
              </xsl:for-each>  
            </colgroup>
            <xsl:variable name="hideHeader">
              <xsl:for-each select="columns/column">
                <xsl:if test="@name='empty'">
                  <xsl:value-of select="1"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:if test="$hideHeader=''">
              <thead style="page-break-inside: avoid !important">
                <tr>
                  <xsl:for-each select="columns/column">
                    <th>
                      <xsl:value-of select="@name"/>
                    </th>
                  </xsl:for-each>
                </tr>
              </thead>
            </xsl:if>
            <tbody style="overflow-wrap:break-word; word-wrap:break-word; page-break-inside: avoid !important">
              <xsl:for-each select="rows/row">
                <tr>
                  <xsl:for-each select="cell">
                    <td>
                      <xsl:value-of select="."/>
                    </td>
                  </xsl:for-each>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
          <br/>
        </xsl:for-each>

      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>