import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { BodkinsService } from './bodkins.service'
import { Router } from '@angular/router'
import { Bodkin } from "./bodkin"
import { NgIf } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BodkinsChangedService } from './bodkins-changed.service';

@Component({
  selector: 'app-bodkins-create',
  standalone: true,
  imports: [NgIf, FormsModule],
  templateUrl: './bodkins-create.component.html',
  styleUrl: './bodkins-create.component.css',
  providers: [],
})
export class BodkinsCreateComponent implements OnInit {
  @Output() added = new EventEmitter();

  bodkin: Bodkin = {id: -1, name: ''}

  constructor(private service: BodkinsService, private router: Router, private changed: BodkinsChangedService) { }

  ngOnInit(): void {
  }

  createBodkin() {
    this.bodkin.id = -1; // force a reset; don't assume the server actually ignores this value
    this.service.postBodkin(this.bodkin).subscribe({
      next: (v) => {console.info("added: " + this.bodkin);},
      error: (e) => console.error(e),
      complete: () => {console.info("create complete"); this.bodkin.name=''; this.changed.bodkinChanged(this.bodkin.id)},
    });
  }

}
