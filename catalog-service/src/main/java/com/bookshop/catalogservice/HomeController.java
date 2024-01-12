package com.bookshop.catalogservice;

import com.bookshop.catalogservice.config.BookshopProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

	private final BookshopProperties bookshopProperties;

	public HomeController(BookshopProperties bookshopProperties) {
		this.bookshopProperties = bookshopProperties;
	}

	@GetMapping("/")
	public String getGreeting() {
		return bookshopProperties.getGreeting();
	}

}
