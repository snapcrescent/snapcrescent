package com.snapcrescent.common;

import java.io.Serializable;
import java.util.Date;

import com.snapcrescent.user.User;

import jakarta.persistence.Column;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.OneToOne;
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
	
	@Version()
	protected Long version;

	private Date creationDateTime;
	
	private Date lastModifiedDateTime;
	
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "CREATED_BY_USER_ID", nullable = true, insertable = false, updatable = false)
	private User createdByUser;

	@Column(name = "CREATED_BY_USER_ID", nullable = true, insertable = true, updatable = true)
	private Long createdByUserId;
	
	private Boolean active = true;
}
