package com.snapcrescent.batch;

public interface BatchService<T extends Batch> {
	public T findById(Long id);
	public T findPendingBatch();
	public void update(T batch);
	public void process(T batch) throws Exception;

}
