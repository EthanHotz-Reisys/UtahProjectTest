body {
 font-family: Arial, Helvetica, sans-serif;
}

@page {
 size: landscape; /*landscape orientation*/
 /*page numbers in the bottom center of each page in the pdf document*/
 @bottom-center {
  content: "Page " counter(page) " of " counter(pages);
  font-family: Arial, Helvetica, sans-serif;
  font-size: 80%;
  border-top: .25pt solid #666;
 }

}
.tg  {border-collapse:collapse;border-spacing:0;border-color:#aabcfe;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:4px 20px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aabcfe;color:#669;background-color:#e8edff;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:4px 20px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#aabcfe;color:#039;background-color:#b9c9fe;}
.tg .tg-baqh{text-align:center;vertical-align:top}
.tg .tg-mb3i{background-color:#D2E4FC;text-align:right;vertical-align:top}
.tg .tg-lqy6{text-align:right;vertical-align:top}
.tg .tg-yw4l{vertical-align:top}
.tg .tg-6k2t{background-color:#D2E4FC;vertical-align:top}

.tg2  {border-collapse:collapse;border-spacing:0;}
.tg2 td{font-family:Arial, sans-serif;font-size:14px;padding:10px 20px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg2 th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 20px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
table {width:960px; margin: 0 auto; margin-bottom: 30px}
table td, table th {
    padding: 15px !important;
}