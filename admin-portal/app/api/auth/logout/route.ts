import { NextResponse } from 'next/server';
import { removeAuthToken } from '@/lib/auth';

export async function POST() {
  try {
    await removeAuthToken();
    return NextResponse.json({ message: 'Logout successful' });
  } catch (error) {
    console.error('Logout error:', error);
    return NextResponse.json(
      { message: 'Logout failed' },
      { status: 500 }
    );
  }
}

