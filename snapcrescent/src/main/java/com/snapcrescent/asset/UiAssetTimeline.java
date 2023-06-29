package com.snapcrescent.asset;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiAssetTimeline {
	
	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date creationDateTime;
	private long count;
	
	public UiAssetTimeline(long count, Date creationDateTime) {
		super();
		this.creationDateTime = creationDateTime;
		this.count = count;
	}
}
