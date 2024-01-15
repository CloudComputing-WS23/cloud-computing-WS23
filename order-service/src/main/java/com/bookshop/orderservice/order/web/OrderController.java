package com.bookshop.orderservice.order.web;

import javax.validation.Valid;

import com.bookshop.orderservice.order.domain.OrderService;
import com.bookshop.orderservice.order.domain.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("orders")
public class OrderController {

	private static final Logger log = LoggerFactory.getLogger(OrderController.class);
	private final OrderService orderService;

	public OrderController(OrderService orderService) {
		this.orderService = orderService;
	}

	@GetMapping
	public Flux<Order> getAllOrders() {
		log.info("Fetching all orders");
		return orderService.getAllOrders();
	}

	@PostMapping
	public Mono<Order> submitOrder(@RequestBody @Valid OrderRequest orderRequest) {
		log.info("Order for {} copies of the book with ISBN {}", orderRequest.quantity(), orderRequest.isbn());
		return orderService.submitOrder(orderRequest.isbn(), orderRequest.quantity());
	}

}
