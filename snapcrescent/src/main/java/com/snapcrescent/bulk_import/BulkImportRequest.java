package com.snapcrescent.bulk_import;


import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class BulkImportRequest {
		
	private String sourceDirectory;
	private String destinationDirectory;
	private Boolean extractMetadataViaInternalService;
	private Boolean importRecursively;
	
	public BulkImportRequest() {
		
	}

	public BulkImportRequest(String sourceDirectory, String destinationDirectory,
			Boolean extractMetadataViaInternalService, Boolean importRecursively) {
		super();
		this.sourceDirectory = sourceDirectory;
		this.destinationDirectory = destinationDirectory;
		this.extractMetadataViaInternalService = extractMetadataViaInternalService;
		this.importRecursively = importRecursively;
	}
	
	
	
	

}
