-- Trigger of DŨNG : Khi mua một đơn hàng nào đó thì số lượng đặt hàng nhỏ hơn hoặc bằng số lượng hiện có và tự động tính tiền
CREATE TRIGGER trg_Check_Order ON CHITIETHOADON FOR INSERT, UPDATE AS
BEGIN
     DECLARE @SoLuongMua int, @SoLuongHienCo int, @GiaSP int, @MaSP NVARCHAR(50), @TongTien int, @MaDH NVARCHAR(50),
	 @SoLuongDaMua int, @MaCT NVARCHAR(50), @PTTT NVARCHAR(100), @TienPhi int

	 SELECT @SoLuongMua = SoLuong, @MaSP = MaSP, @TongTien = ThanhTien, @MaDH = MaDH, @MaCT = MaCTHD FROM inserted

	 SELECT @SoLuongDaMua = SoLuong FROM deleted WHERE MaCTHD = @MaCT

	 SELECT @PTTT = PTTT FROM DONHANG WHERE MaDH = @MaDH

	 SELECT @TienPhi = PhiTT FROM PAYMENT WHERE MaPTTT = @PTTT

	 SELECT @SoLuongHienCo = SoluongSP, @GiaSP = GiaSP FROM PRODUCT WHERE MaSP = @MaSP

	 IF(@SoLuongMua > @SoLuongHienCo + @SoLuongDaMua)
	 BEGIN
	    PRINT N'Số lượng sản phẩm trong kho không đủ để mua hàng.'
		ROLLBACK TRAN
	 END
	 ELSE IF(@TongTien != @GiaSP * @SoLuongMua)
	 BEGIN
	    UPDATE CHITIETHOADON SET ThanhTien = @GiaSP * @SoLuongMua WHERE MaCTHD = @MaCT
		UPDATE DONHANG SET TongTien = (@GiaSP * @SoLuongMua) + @TienPhi WHERE MaDH = @MaDH
	 END
END

GO

DELETE FROM DONHANG WHERE MaDH = 'DH006'

INSERT INTO DONHANG VALUES('DH006','2022-03-08',N'Đang giao',0,'KH003','SP001','TT01')

INSERT INTO CHITIETHOADON VALUES ('CT006',3,20000,0,'DH006','SP001')

GO
