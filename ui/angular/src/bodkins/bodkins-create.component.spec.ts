import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BodkinsComponent } from './bodkins.component';

describe('BodkinsComponent', () => {
  let component: BodkinsComponent;
  let fixture: ComponentFixture<BodkinsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BodkinsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BodkinsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
