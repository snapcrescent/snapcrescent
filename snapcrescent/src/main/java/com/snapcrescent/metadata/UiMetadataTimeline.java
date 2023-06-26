package com.snapcrescent.metadata;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiMetadataTimeline {
	
	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date creationDateTime;
	private long count;
	
	public UiMetadataTimeline(long count, Date creationDateTime) {
		super();
		this.creationDateTime = creationDateTime;
		this.count = count;
	}
}
