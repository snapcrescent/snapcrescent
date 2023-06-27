package com.snapcrescent.thumbnail;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

@Repository
public class ThumbnailRepository extends BaseRepository<Thumbnail>{
			
			public ThumbnailRepository() {
				super(Thumbnail.class);
			}

}
