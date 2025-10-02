import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getTest(): string {
    return '1.0.0';
  }

  getHello(): string {
    return 'Hello World! 555';
  }
}
