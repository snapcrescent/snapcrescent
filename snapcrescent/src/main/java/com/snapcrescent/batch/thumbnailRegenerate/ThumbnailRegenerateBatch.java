package com.snapcrescent.batch.thumbnailRegenerate;

import com.snapcrescent.batch.Batch;

import jakarta.persistence.Entity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class ThumbnailRegenerateBatch extends Batch {

	private static final long serialVersionUID = -4250460739319965956L;

}
