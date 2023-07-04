package com.snapcrescent.thumbnail;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;

@Component
public class ThumbnailConverter extends BaseConverter<Thumbnail, UiThumbnail>{
	
	@Autowired
	private ThumbnailRepository thumbnailRepository;
	
	public ThumbnailConverter() {
		super(Thumbnail.class, UiThumbnail.class);
	}
	
	@Override
	public Thumbnail loadEntityById(Long id) {
		return thumbnailRepository.loadById(id);
	}
}
