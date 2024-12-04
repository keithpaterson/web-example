import { TestBed } from '@angular/core/testing';

import { BodkinsService } from './bodkins.service';

describe('BodkinsService', () => {
  let service: BodkinsService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(BodkinsService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
