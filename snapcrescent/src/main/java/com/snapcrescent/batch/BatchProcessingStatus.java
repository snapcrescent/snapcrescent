package com.snapcrescent.batch;

import lombok.Data;

@Data
public class BatchProcessingStatus<P,R> {
	
	private P payload;
	private R result;
	
	public BatchProcessingStatus(P payload, R result) {
		super();
		this.payload = payload;
		this.result = result;
	}
	

}
