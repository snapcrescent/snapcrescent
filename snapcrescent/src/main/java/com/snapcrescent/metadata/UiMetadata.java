package com.snapcrescent.metadata;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.snapcrescent.common.beans.BaseUiBean;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiMetadata extends BaseUiBean {

	private static final long serialVersionUID = 1567235158787189351L;
	
	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date creationDateTime;

	private String name;
	private String internalName;
	private String mimeType;
	private int orientation;
	private Long height;
	private Long width;
	private long size;

}
