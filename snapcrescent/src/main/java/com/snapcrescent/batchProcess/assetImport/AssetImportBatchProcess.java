package com.snapcrescent.batchProcess.assetImport;

import java.util.List;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.batchProcess.BatchProcess;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToMany;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class AssetImportBatchProcess extends BatchProcess {

	private static final long serialVersionUID = -4250460739319965956L;
	
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "assetImportBatchProcess", cascade = CascadeType.DETACH)
	private List<Asset> assets;
}
