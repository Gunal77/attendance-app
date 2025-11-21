import { NextRequest, NextResponse } from 'next/server';
import { authAPI } from '@/lib/api';
import { setAuthToken } from '@/lib/auth';

export async function POST(request: NextRequest) {
  try {
    const { email, password } = await request.json();

    if (!email || !password) {
      return NextResponse.json(
        { message: 'Email and password are required' },
        { status: 400 }
      );
    }

    const response = await authAPI.login(email, password);
    
    // Set the token in HttpOnly cookie
    await setAuthToken(response.token);

    return NextResponse.json({
      message: 'Login successful',
      user: response.user,
    });
  } catch (error: any) {
    console.error('Login error:', error);
    return NextResponse.json(
      { message: error.response?.data?.message || 'Login failed' },
      { status: error.response?.status || 500 }
    );
  }
}

