package com.bookshop.orderservice.config;

import java.net.URI;

import javax.validation.constraints.NotNull;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "bookshop")
public record ClientProperties (

	@NotNull
	URI catalogServiceUri

){}
