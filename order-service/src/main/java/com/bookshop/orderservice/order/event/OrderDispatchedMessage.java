package com.bookshop.orderservice.order.event;

public record OrderDispatchedMessage (
		Long orderId
){}
