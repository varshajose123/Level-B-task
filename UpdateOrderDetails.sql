CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(4, 2) = NULL
AS
BEGIN
    DECLARE @CurrentUnitPrice DECIMAL(18, 2)
    DECLARE @CurrentQuantity INT
    DECLARE @CurrentDiscount DECIMAL(4, 2)
    DECLARE @UnitsInStock INT
    DECLARE @ReorderLevel INT

    -- Get Current Order Details
    SELECT 
        @CurrentUnitPrice = UnitPrice, 
        @CurrentQuantity = Quantity, 
        @CurrentDiscount = Discount
    FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Use Current Values if NULL
    SET @UnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @CurrentQuantity);
    SET @Discount = ISNULL(@Discount, @CurrentDiscount);

    -- Get Product Details
    SELECT 
        @UnitsInStock = UnitsInStock, 
        @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    -- Adjust Stock for Quantity Change
    IF @Quantity IS NOT NULL AND @Quantity != @CurrentQuantity
    BEGIN
        IF @UnitsInStock + @CurrentQuantity < @Quantity
        BEGIN
            PRINT 'Not enough stock to fulfill the updated order.';
            RETURN;
        END;

        -- Update Stock
        UPDATE Products
        SET UnitsInStock = UnitsInStock + @CurrentQuantity - @Quantity
        WHERE ProductID = @ProductID;
    END;

    -- Update Order Detail
    UPDATE OrderDetails
    SET 
        UnitPrice = @UnitPrice, 
        Quantity = @Quantity, 
        Discount = @Discount
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to update the order. Please try again.';
        RETURN;
    END;
END;
