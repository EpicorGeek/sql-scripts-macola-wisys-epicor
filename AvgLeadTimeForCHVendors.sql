SELECT     AVG(datediff(day,(CONVERT(date, PH.ord_dt, 101)),(CONVERT(date,PL.extra_8 , 101))))
                    FROM         dbo.apvenfil_sql AS AP INNER JOIN
                      dbo.poordhdr_sql AS PH ON AP.vend_no = PH.vend_no INNER JOIN
                      dbo.poordlin_sql AS PL ON PL.ord_no = PH.ord_no AND PL.vend_no = PH.vend_no INNER JOIN
                      dbo.humres AS HR ON PL.byr_plnr = HR.res_id LEFT OUTER JOIN
                      dbo.poshpfil_sql AS PS ON PS.ship_to_cd = PH.ship_to_cd
WHERE     (PL.qty_received = PL.qty_ordered) AND (LTRIM(PL.vend_no) IN ('1697')) AND 
                    (PL.receipt_dt > DATEADD(day, - 180, GETDATE())) and
                    not PL.extra_8 is null