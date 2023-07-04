package com.snapcrescent.metadata;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;

@Component
public class MetadataConverter extends BaseConverter<Metadata, UiMetadata> {
	
	@Autowired
	private MetadataRepository metadataRepository;
	
	public MetadataConverter() {
		super(Metadata.class, UiMetadata.class);
	}
	
	@Override
	public Metadata loadEntityById(Long id) {
		return metadataRepository.loadById(id);
	}
}
