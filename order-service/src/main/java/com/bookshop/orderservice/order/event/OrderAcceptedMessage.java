package com.bookshop.orderservice.order.event;

public record OrderAcceptedMessage (
		Long orderId
){}
