package com.snapcrescent.batch;

import java.util.Date;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.utils.Constant.BatchStatus;

import jakarta.persistence.Basic;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PostLoad;
import jakarta.persistence.Transient;
import lombok.Data;
import lombok.EqualsAndHashCode;

@MappedSuperclass
@Data
@EqualsAndHashCode(callSuper = false)
public class Batch extends BaseEntity {

	private static final long serialVersionUID = -4250460739319965956L;
	
	private String name;
	
	private Date startDateTime;
	private Date endDateTime;
	
	@Basic
	private Integer batchStatus;
	
	@Transient
    private BatchStatus batchStatusEnum;

	@PostLoad
    void fillTransient() {
		if(batchStatus > 0) {
			this.batchStatusEnum = BatchStatus.findById(batchStatus);
		}
	}
}
