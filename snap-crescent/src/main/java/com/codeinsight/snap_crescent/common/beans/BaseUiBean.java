package com.codeinsight.snap_crescent.common.beans;

import java.io.Serializable;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

@Data
public abstract class BaseUiBean implements Serializable {

	private static final long serialVersionUID = 6486192088436426369L;

	protected Long id;
	
	protected Long version;

	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date creationDatetime;

	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date lastModifiedDatetime;

	private Boolean active;

}
