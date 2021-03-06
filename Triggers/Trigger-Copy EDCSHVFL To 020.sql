/****** Object:  Trigger [dbo].[Insert_to_ARSHTTBL]    Script Date: 03/29/2011 13:59:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER trigger [dbo].[Insert_to_020]
            on [001].[dbo].[edcshvfl_sql]

			after insert
			AS

BEGIN


	Insert Into [020].[dbo].[edcshvfl_sql] (code, cust_num, mac_ship_via, pay_type, carrier, id_scac_code, transport_type,misc_info_1, misc_num_info_1, misc_num_info_2, misc_info_3, misc_num_info_4, misc_num_info_5)
 
      Select Distinct code, cust_num, mac_ship_via, pay_type, carrier, id_scac_code, transport_type,misc_info_1, misc_num_info_1, misc_num_info_2, misc_info_3, misc_num_info_4, misc_num_info_5
      From inserted
      WHERE not(mac_ship_via IN (SELECT mac_ship_via from [020].[dbo].[edcshvfl_sql]))
      
      END
