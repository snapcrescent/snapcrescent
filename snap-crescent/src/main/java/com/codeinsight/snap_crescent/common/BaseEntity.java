package com.codeinsight.snap_crescent.common;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;
import javax.persistence.Version;

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

	private Date creationDatetime;
	
	private Date lastModifiedDatetime;
	
	private Boolean active = true;

}
