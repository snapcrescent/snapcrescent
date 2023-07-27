package com.snapcrescent.batch.assetImport;

import com.snapcrescent.batch.Batch;

import jakarta.persistence.Entity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class AssetImportBatch extends Batch {

	private static final long serialVersionUID = -4250460739319965956L;
	private String filesBasePath;
}
