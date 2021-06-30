package com.codeinsight.snap_crescent.thumbnail;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class ThumbnailRepository extends BaseRepository<Thumbnail>{
			
			public ThumbnailRepository() {
				super(Thumbnail.class);
			}

}
