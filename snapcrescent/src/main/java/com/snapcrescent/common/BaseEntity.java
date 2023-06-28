package com.snapcrescent.common;

import java.io.Serializable;
import java.util.Date;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.Version;

import lombok.Data;

@MappedSuperclass
@Data
public abstract class BaseEntity implements Serializable{
	
	private static final long serialVersionUID = 6486192088436426369L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(unique = true, nullable = false)
	protected Long id;
	
	@Version
	protected Long version;

	private Date creationDateTime;
	
	private Date lastModifiedDateTime;
	
	private Boolean active = true;

}
