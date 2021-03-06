USE [001]
GO
/****** Object:  StoredProcedure [dbo].[wsCreateEmptyPallets]    Script Date: 02/22/2011 10:59:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[wsCreateEmptyPallets] (@qty int, @store varchar(12))
As
Begin

Declare @cnt int
Declare @pallet Varchar(30)
Declare @pallet_ucc128 Varchar(50)

Set @cnt = 0

If @store Is Null
  Set @store = ''

Begin Transaction

While @qty > @cnt

  Begin
    Set @pallet        = (Select Right(Replicate(' ', 30) + Convert(varchar, Max(Convert(int, IsNull(pallet, 0))) + 1), 30) From wspikpak)
    Set @pallet_ucc128 = (Select Right(Replicate(' ', 50) + Convert(varchar, Max(Convert(int, IsNull(@pallet, 0)))), 50))
    
    If @Pallet_UCC128 Is Null
      Set @pallet_ucc128 = '                                                 1'

    If @Pallet Is Null
      Set @pallet = '                             1'

  
/*This section updated by Bryan: Insert Pallet and PalletUCC values into Carton and CartonUCC fields in addition to the pallet fields.
------*/
    Insert Into wspikpak (shipment, ord_no, line_no, item_no,item_desc,loc,qty,pallet,pallet_ucc128, Carton, Carton_UCC128, BinSLID, load_dt,shipped,[weight],length,width,height)
    Values ('', '', 0, '',@store,'',0, @pallet, @pallet_ucc128, @pallet, @pallet_ucc128, Newid(), GETDATE(), 'N', 0, 0, 0, 0)
/*------*/
    If @@error <> 0 Begin
      Rollback Transaction
      Goto on_error
    End

    Update wssettings_sql set longvalue = (Select Max(convert(int,pallet)) from wspikpak) + 1 Where settinggroup = 'pikpak' and settingname = 'nextpallet'

    If @@error <> 0 Begin
      Rollback Transaction
      Goto on_error
    End

    Set @cnt = @cnt + 1

  End

End

Commit Transaction

on_error:

Return