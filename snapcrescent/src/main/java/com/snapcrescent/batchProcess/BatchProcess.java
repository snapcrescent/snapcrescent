package com.snapcrescent.batchProcess;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.utils.Constant.BatchProcessStatus;

import jakarta.persistence.Basic;
import jakarta.persistence.Entity;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PostLoad;
import jakarta.persistence.Transient;
import lombok.Data;
import lombok.EqualsAndHashCode;

@MappedSuperclass
@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class BatchProcess extends BaseEntity {

	private static final long serialVersionUID = -4250460739319965956L;
	
	@Basic
	private Integer batchProcessStatus;
	
	@Transient
    private BatchProcessStatus batchProcessStatusEnum;

	@PostLoad
    void fillTransient() {
		if(batchProcessStatus > 0) {
			this.batchProcessStatusEnum = BatchProcessStatus.findById(batchProcessStatus);
		}
	}
}
