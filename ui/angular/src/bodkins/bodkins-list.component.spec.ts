import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BodkinsListComponent } from './bodkins-list.component';

describe('BodkinsListComponent', () => {
  let component: BodkinsListComponent;
  let fixture: ComponentFixture<BodkinsListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BodkinsListComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BodkinsListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
