package com.bookshop.catalogservice.demo;

import java.util.List;

import com.bookshop.catalogservice.domain.Book;
import com.bookshop.catalogservice.domain.BookRepository;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Profile;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@Profile("testdata")
public class BookDataLoader {

	private final BookRepository bookRepository;

	public BookDataLoader(BookRepository bookRepository) {
		this.bookRepository = bookRepository;
	}

	@EventListener(ApplicationReadyEvent.class)
	public void loadBookTestData() {
		bookRepository.deleteAll();
		var book1 = Book.of("1234567891", "Cloud Native Spring in Action", "Thomas Vitale", 9.90, "Manning Publications Co.");
		var book2 = Book.of("1234567892", "Kubernetes in Action ", "Marko Luksa", 12.90, "Manning Publications Co.");
		bookRepository.saveAll(List.of(book1, book2));
	}

}
