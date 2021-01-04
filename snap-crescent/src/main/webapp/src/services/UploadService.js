import { multipartData } from '../utils/ApiUtil';

const UPLOAD_URL = 'upload';

export const upload = (props, options, showLoader = true) => {
  return multipartData(UPLOAD_URL, props, options, showLoader);
}