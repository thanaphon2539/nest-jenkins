import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getTest(): string {
    return 'Hello World!';
  }

  getHello(): string {
    return 'Hello World! 555';
  }
}
