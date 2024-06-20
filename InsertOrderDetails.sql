CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(4, 2) = 0
AS
BEGIN
    DECLARE @ProductUnitPrice DECIMAL(18, 2)
    DECLARE @UnitsInStock INT
    DECLARE @ReorderLevel INT

    -- Get Product Details
    SELECT @ProductUnitPrice = UnitPrice, @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    -- Use Product Unit Price if not provided
    IF @UnitPrice IS NULL
    BEGIN
        SET @UnitPrice = @ProductUnitPrice;
    END

    -- Check Stock
    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock to fulfill the order.';
        RETURN;
    END

    -- Insert Order Detail
    INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Update Stock
    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    -- Check for Reorder Level
    IF @UnitsInStock - @Quantity < @ReorderLevel
    BEGIN
        PRINT 'Quantity in stock has dropped below the reorder level.';
    END
END;
