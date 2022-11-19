package com.codeinsight.snap_crescent.bulk_import;

public interface BulkImportService {
	
	public void bulkImportFromDirectory(String sourceDirectory, String destinationDirectory) throws Exception;

}
