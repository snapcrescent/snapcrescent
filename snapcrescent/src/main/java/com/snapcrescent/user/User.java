package com.snapcrescent.user;

import com.snapcrescent.common.BaseEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class User extends BaseEntity {

	private static final long serialVersionUID = -5417001592780159971L;

	@Column(nullable = false)
	private String firstName;

	private String lastName;

	@Column(unique = true, nullable = false)
	private String username;

	@Column(nullable = false)
	private String password;

}
