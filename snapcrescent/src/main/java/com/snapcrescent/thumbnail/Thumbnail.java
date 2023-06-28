package com.snapcrescent.thumbnail;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

import com.snapcrescent.common.BaseEntity;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class Thumbnail extends BaseEntity {

	private static final long serialVersionUID = 1567235158787189351L;

	@Column(nullable = false)
	private String name;

	@Column(nullable = false)
	private String path;
}
