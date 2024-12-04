import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { BodkinsListComponent } from '../bodkins/bodkins-list.component';
import { BodkinsCreateComponent } from '../bodkins/bodkins-create.component';
import { BodkinsChangedService } from '../bodkins/bodkins-changed.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, BodkinsListComponent, BodkinsCreateComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'webkins';
}
