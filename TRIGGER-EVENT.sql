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




--- Trigger of CẢM: Tạo trigger khi tiến hành cập nhật SoluongSP của bảng PRODUCT thì số lượng sản phẩm >= số lượng đặt hàng của bảng CHITIETHOADON

CREATE TRIGGER Tr_update
	ON dbo.PRODUCT
FOR UPDATE 
AS 
	IF(SELECT SUM(dbo.PRODUCT.SoluongSP)
		FROM dbo.PRODUCT INNER JOIN Inserted 
			ON Inserted.MaSP = PRODUCT.MaSP )<
	(SELECT SUM(dbo.CHITIETHOADON.SoLuong)
		FROM dbo.CHITIETHOADON INNER JOIN Inserted 
			ON Inserted.MaSP = CHITIETHOADON.MaSP)
BEGIN 
	PRINT N'tổng số lượng nhập nhỏ hơn số lượng đặt hàng'
	ROLLBACK TRAN
END
 

 	--cập nhập số lượng lớn hơn SL hiện có

  UPDATE dbo.PRODUCT
  SET SoluongSP = 30 WHERE MaSP = 'SP001'

  SELECT * FROM dbo.PRODUCT

	 --cập nhập số lượng nhỏ hơn SL hiện có

 UPDATE dbo.PRODUCT
 SET SoluongSP = 1 WHERE MaSP = 'SP001'

 SELECT * FROM dbo.PRODUCT
 
 -- Event OF CẢM: Tạo 1 event cứ mỗi 15 ngày sẽ cập nhật lại  GiaSP của bảng PRODUCT 1 lần với GiaSP cố định là 2000 trên mỗi SP. 
 
CREATE EVENT eve_update   
ON SCHEDULE EVERY 15 day
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 MONTH
    DO
      UPDATE PRODUCT SET GiaSP = GiaSP + 2000;
      
	select * from product;
